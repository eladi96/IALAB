package ialab_torta;

import org.apache.commons.math3.linear.*;
import org.apache.commons.math3.filter.KalmanFilter;
import org.apache.commons.math3.filter.MeasurementModel;
import org.apache.commons.math3.filter.ProcessModel;
import org.apache.commons.math3.filter.DefaultMeasurementModel;
import org.apache.commons.math3.filter.DefaultProcessModel;
import org.apache.commons.math3.random.JDKRandomGenerator;
import org.apache.commons.math3.random.RandomGenerator;

import java.awt.desktop.SystemSleepEvent;
import java.io.FileWriter;
import java.io.IOException;

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
        // rumore di osservazione per la posizione
        double[] measurementNoise = new double[]{0.0000001d, 10d, 100d};

        // tre matrici di covarianza per la transizione (errore basso, medio, alto)
        RealMatrix nullo = new Array2DRowRealMatrix(new double[][]{
                {0.01, 0},
                {0, 0.01}});
        RealMatrix medio = new Array2DRowRealMatrix(new double[][]{
                {10, 0},
                {0, 10}});
        RealMatrix alto = new Array2DRowRealMatrix(new double[][]{
                {100, 0},
                {0, 100}});
        RealMatrix[] noiseCov = new RealMatrix[]{nullo, medio, alto};

        //TODO-> variare la P0 iniziale dello stato
        //TODO facoltativo -> simulare un processo (più o meno) non lineare e vedere come si comporta il KF

        System.out.format("%5s", "Stato");
        System.out.format("%15s", "Posizione");
        System.out.format("%15s", "Posizione Kalman");
        System.out.format("%15s", "Velocità");
        System.out.format("%15s", "Velocità Kalman");
        System.out.format("%15s", "Errore Pos");
        System.out.format("%15s", "Errore Vel");
        System.out.format("%15s", "KalmanGain");

        //System.out.println("Stato \t Posizione \t Posizione kalman \t Velocità \t Velocita kalman \t ErrorePos \t ErroreVel \t KalmanGain");
        experiment(dt, measurementNoise[2], noiseCov[2]);
        /*for (double m : measurementNoise) {
            for (RealMatrix cov : noiseCov) {
                experiment(dt, m, cov);
            }
        }*/


    }

    private static void experiment(double dt, double measurementNoise, RealMatrix noiseCov) {
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
        RealMatrix Q = noiseCov;

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
            RealVector pNoise = tmpPNoise.mapMultiply(measurementNoise * rand.nextGaussian());

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

            risultati(i, x, position, velocity, kalmanGain);

        }
    }

    private static void risultati(int i, RealVector x, double position, double velocity, RealMatrix k_gain) {
        /*FileWriter writer = null;
        try {
            writer = new FileWriter("risultati_KalmanFilter.csv");
            writer.write("Stato %s Posizione %s Posizione kalman %s Velocità %s Velocita kalman %s ErrorePos %s ErroreVel %s KalmanGain");
            writer.write();

        } catch (IOException e) {
            e.printStackTrace();
        }*/

        System.out.format("%d %1.13f %1.13f %1.13f %1.13f %1.13f %1.13f %1.13f", i, x.getEntry(0), position, x.getEntry(1), velocity, Math.abs(x.getEntry(0) - position), Math.abs(x.getEntry(1) - velocity), k_gain.getEntry(0, 0));
//        System.out.println("Stato " + (i + 1));
//        System.out.println("Posizione: " + x.getEntry(0));
//        System.out.println("Posizione stimata con kalman: " + position);
//        System.out.println("Velocità: " + x.getEntry(1));
//        System.out.println("Velocita stimata con kalman': " + velocity);
//        System.out.println("Errore del processo per la posizione: " + Math.abs(x.getEntry(0) - position));
//        System.out.println("Errore del processo per la velocità: " + Math.abs(x.getEntry(1) - velocity));
//        System.out.println("KalmanGain: " + k_gain.getEntry(0, 0) + "\n");
        System.out.println();

    }

    private void printMatrix(RealMatrix M) {
        System.out.println("\nM:");
        for (int i = 0; i < M.getRowDimension(); i++) {
            for (int j = 0; j < M.getColumnDimension(); j++) {
                System.out.print(M.getEntry(i, j) + " ");
            }
            System.out.print("\n");
        }
    }
}
