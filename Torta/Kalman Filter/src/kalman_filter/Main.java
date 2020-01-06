package ialab_torta;

import org.apache.commons.math3.linear.*;
import org.apache.commons.math3.filter.KalmanFilter;
import org.apache.commons.math3.filter.MeasurementModel;
import org.apache.commons.math3.filter.ProcessModel;
import org.apache.commons.math3.filter.DefaultMeasurementModel;
import org.apache.commons.math3.filter.DefaultProcessModel;
import org.apache.commons.math3.random.JDKRandomGenerator;
import org.apache.commons.math3.random.RandomGenerator;


/*
Inputs: u, z
Outputs: x, p
Costanti: A, B, H, Q, R
 */

public class Main {

    public static void main(String[] args) {
        System.out.println("*********** IALAB pt. 3.2 ***********");
        System.out.println("*********** Kalman Filter ***********");

        // intervallo di tempo discreto
        double dt = 0.1d;
        // rumore di osservazione per la posizione (m)
        double measurementNoise = 10d;
        // rumore dell'accelerazione (m/s^2)
        double accelNoise = 0.2d;

        // Matrice di transizione di stato.
        // Fondamentalmente, moltiplica lo stato per questo e aggiungi i fattori di controllo e otterrai una previsione dello stato per il passaggio successivo.
        // A = [ 1 dt ]
        //     [ 0  1 ]
        RealMatrix A = new Array2DRowRealMatrix(new double[][]{{1, dt}, {0, 1}});

        // Matrice di controllo.
        // Questo è usato per definire equazioni lineari per qualsiasi fattore di controllo.
        // B = [ dt^2/2 ]
        //     [ dt     ]
        RealMatrix B = new Array2DRowRealMatrix(new double[][]{{Math.pow(dt, 2d) / 2d}, {dt}});

        // Matrice di osservazione.
        // Moltiplica un vettore di stato per H per tradurlo in un vettore di misurazione.
        // Nella pratica collega lo stato con la misura del rumore.
        // H = [ 1 0 ]
        RealMatrix H = new Array2DRowRealMatrix(new double[][]{{1d, 0d}});

        // Stima più recente dell'attuale stato "vero".
        // è un vettore contenente di volta in volta gli attuali stati del mondo
        // x = [ 0 0 ]
        RealVector x = new ArrayRealVector(new double[]{0, 0});

        //PER IL KALMAN GAIN: Q e R
        // Covarianza stimata dell'errore di processo.
        // Q = [ dt^4/4 dt^3/2 ]
        //     [ dt^3/2 dt^2   ]
        RealMatrix tmp = new Array2DRowRealMatrix(new double[][]{
                {Math.pow(dt, 4d) / 4d, Math.pow(dt, 3d) / 2d},
                {Math.pow(dt, 3d) / 2d, Math.pow(dt, 2d)}});
        RealMatrix Q = tmp.scalarMultiply(Math.pow(accelNoise, 2));

        // Covarianza dell'errore di misura stimata.
        // R = [ measurementNoise^2 ]
        RealMatrix R = new Array2DRowRealMatrix(new double[]{Math.pow(measurementNoise, 2)});

        // Stima più recente dell'errore medio per ciascuna parte dello stato.
        // Error covariance matrix: matrice di covarianza per l'errore
        // P0 = [ 1 1 ]
        //      [ 1 1 ]
        RealMatrix P0 = new Array2DRowRealMatrix(new double[][]{{1, 1}, {1, 1}});

        // Vettore di controllo dell'input.
        // Ciò indica l'entità del controllo di qualsiasi sistema o utente sulla situazione.
        // Nel nostro caso la crescita è costante: la velocità aumenta di 0.1 m/s per ciclo
        RealVector u = new ArrayRealVector(new double[]{0.1d});

        // modello del moto
        ProcessModel pm = new DefaultProcessModel(A, B, Q, x, P0);

        // modello della osservazione
        MeasurementModel mm = new DefaultMeasurementModel(H, R);

        //filtro
        KalmanFilter filter = new KalmanFilter(pm, mm);

        RandomGenerator rand = new JDKRandomGenerator();

        // vettore per il rumore del processo
        RealVector tmpPNoise = new ArrayRealVector(new double[]{Math.pow(dt, 2d) / 2d, dt});
        //vettore per il rumore della osservazione
        RealVector mNoise = new ArrayRealVector(1);

        // matrice di covarianza dell'errore del filtro
        RealMatrix errorCovariance = filter.getErrorCovarianceMatrix();

        //PER IL KALMAN GAIN
        RealMatrix HPH;
        RealMatrix kalmanGain;

        // fase di predizione
        // iterate 60 steps
        for (int i = 0; i < 60; i++) {
            // stima lo stato successivo
            filter.predict(u);

            // calcolo il rumore gaussiano per le transizioni di stato
            RealVector pNoise = tmpPNoise.mapMultiply(accelNoise * rand.nextGaussian());

            // x = A * x + B * u + pNoise
            x = A.operate(x).add(B.operate(u)).add(pNoise);

            // calcolo il rumore gaussiano per le misurazioni
            mNoise.setEntry(0, measurementNoise * rand.nextGaussian());

            // Vettore di misurazione.
            // Questo contiene la misurazione del mondo reale che abbiamo ricevuto in questo passaggio temporale.
            // z = H * x + m_noise
            RealVector z = H.operate(x).add(mNoise);

            // corregge la stiama dello stato con l'errore z
            filter.correct(z);

            //Kalman Gain
            //H*P*H'*(H*P*H'+R)^-1
            HPH = H.multiply(errorCovariance).multiply(H.transpose());
            kalmanGain = HPH.multiply(MatrixUtils.inverse(HPH.add(R)));

            double position = filter.getStateEstimation()[0];
            double velocity = filter.getStateEstimation()[1];

            System.out.println("Stato " + (i + 1));
            System.out.println("Posizione: " + x.getEntry(0));
            System.out.println("Posizione stimata con kalman: " + position);
            System.out.println("Velocità: " + x.getEntry(1));
            System.out.println("Velocita stimata con kalman': " + velocity);
            System.out.println("Errore del processo per la posizione: " + Math.abs(x.getEntry(0) - position));
            System.out.println("Errore del processo per la velocità: " + Math.abs(x.getEntry(1) - velocity));
            System.out.println("KalmanGain: " + kalmanGain.getEntry(0, 0) + "\n");
            System.out.println();
        }
    }
}
