package kalman_filter;

import org.apache.commons.math3.linear.Array2DRowRealMatrix;
import org.apache.commons.math3.linear.ArrayRealVector;
import org.apache.commons.math3.linear.RealMatrix;
import org.apache.commons.math3.linear.RealVector;
import org.apache.commons.math3.filter.KalmanFilter;
import org.apache.commons.math3.filter.MeasurementModel;
import org.apache.commons.math3.filter.ProcessModel;
import org.apache.commons.math3.filter.DefaultMeasurementModel;
import org.apache.commons.math3.filter.DefaultProcessModel;
import org.apache.commons.math3.random.JDKRandomGenerator;
import org.apache.commons.math3.random.RandomGenerator;

public class Main {

    public static void main(String[] args) {
        System.out.println("*********** IALAB pt. 3.2 ***********");
        System.out.println("*********** Kalman Filter ***********");

        // intervallo di tempo discreto
        double dt = 0.1d;
        // rumore di misurazione per la posizione (m)
        double measurementNoise = 10d;
        // rumore dell'accelerazione (m/s^2)
        double accelNoise = 0.2d;

        // matrice di transizione dello stato
        // A = [ 1 dt ]
        //     [ 0  1 ]
        RealMatrix A = new Array2DRowRealMatrix(new double[][]{{1, dt}, {0, 1}});

        // matrice per l'ingresso di controllo opzionale
        // control input matrix
        // B = [ dt^2/2 ]
        //     [ dt     ]
        RealMatrix B = new Array2DRowRealMatrix(new double[][]{{Math.pow(dt, 2d) / 2d}, {dt}});

        // collega lo stato con la misura del rumore
        // H = [ 1 0 ]
        RealMatrix H = new Array2DRowRealMatrix(new double[][]{{1d, 0d}});

        // vettore per gli stati
        // x = [ 0 0 ]
        RealVector x = new ArrayRealVector(new double[]{0, 0});

        //
        RealMatrix tmp = new Array2DRowRealMatrix(new double[][]{
                {Math.pow(dt, 4d) / 4d, Math.pow(dt, 3d) / 2d},
                {Math.pow(dt, 3d) / 2d, Math.pow(dt, 2d)}});

        // rumore esterno
        // Q = [ dt^4/4 dt^3/2 ]
        //     [ dt^3/2 dt^2   ]
        RealMatrix Q = tmp.scalarMultiply(Math.pow(accelNoise, 2));

        // distribuzione iniziale
        // P0 = [ 1 1 ]
        //      [ 1 1 ]
        RealMatrix P0 = new Array2DRowRealMatrix(new double[][]{{1, 1}, {1, 1}});

        // matrice di covarianza per il rumore della misurazione
        // R = [ measurementNoise^2 ]
        RealMatrix R = new Array2DRowRealMatrix(new double[]{Math.pow(measurementNoise, 2)});

        // controllo dell'input: crescita costante, la velocità aumenta di 0.1 m/s per ciclo
        RealVector u = new ArrayRealVector(new double[]{0.1d});

        // modello del moto
        ProcessModel pm = new DefaultProcessModel(A, B, Q, x, P0);

        // modello della misurazione
        MeasurementModel mm = new DefaultMeasurementModel(H, R);

        //filtro
        KalmanFilter filter = new KalmanFilter(pm, mm);

        RandomGenerator rand = new JDKRandomGenerator();

        //
        RealVector tmpPNoise = new ArrayRealVector(new double[]{Math.pow(dt, 2d) / 2d, dt});
        RealVector mNoise = new ArrayRealVector(1);

        // fase di predizione
        // iterate 60 steps
        for (int i = 0; i < 60; i++) {
            filter.predict(u);

            // simulate the process
            RealVector pNoise = tmpPNoise.mapMultiply(accelNoise * rand.nextGaussian());

            // x = A * x + B * u + pNoise
            x = A.operate(x).add(B.operate(u)).add(pNoise);

            // simulate the measurement
            mNoise.setEntry(0, measurementNoise * rand.nextGaussian());

            // z = H * x + m_noise
            RealVector z = H.operate(x).add(mNoise);

            filter.correct(z);

            double position = filter.getStateEstimation()[0];
            double velocity = filter.getStateEstimation()[1];

            System.out.println("Fase: " + (i+1));
            System.out.println("Posizione: " + position);
            System.out.println("Velocita': " + velocity + "\n");
        }

    }
}
