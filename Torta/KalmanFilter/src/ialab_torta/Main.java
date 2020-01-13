package ialab_torta;

import org.apache.commons.math3.linear.*;
import org.apache.commons.math3.filter.KalmanFilter;
import org.apache.commons.math3.filter.MeasurementModel;
import org.apache.commons.math3.filter.ProcessModel;
import org.apache.commons.math3.filter.DefaultMeasurementModel;
import org.apache.commons.math3.filter.DefaultProcessModel;
import org.apache.commons.math3.random.JDKRandomGenerator;
import org.apache.commons.math3.random.RandomGenerator;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/*
Inputs: u, z
Outputs: x, p
Costanti: A, B, H, Q, R
 */
public class Main {

    public static void main(String[] args) throws IOException {
        // intervallo di tempo discreto
        double dt = 0.1d;
        // rumore di osservazione per la posizione
        double[] measurementNoise = new double[]{0.001d, 10d, 100d};

        // tre matrici di covarianza per la transizione (errore basso, medio, alto)
        RealMatrix nullo = new Array2DRowRealMatrix(new double[][]{
                {0.001, 0},
                {0, 0.001}});
        RealMatrix medio = new Array2DRowRealMatrix(new double[][]{
                {10, 0},
                {0, 10}});
        RealMatrix alto = new Array2DRowRealMatrix(new double[][]{
                {100, 0},
                {0, 100}});
        RealMatrix[] noiseCov = new RealMatrix[]{nullo, medio, alto};

        //String[] nameForFile = new String[]{"basso, medio, alto"};
        List<String> nameForFile = new ArrayList<String>();
        nameForFile.add("basso");
        nameForFile.add("medio");
        nameForFile.add("alto");


        //System.out.println("current dir = " + dir);
        try {
            for (int i = 0; i < measurementNoise.length; i++) {
                for (int j = 0; j < noiseCov.length; j++) {

                    final String dirFolder = System.getProperty("user.dir") + "/Risultati";
                    File fileFolder = new File(dirFolder);
                    if (!fileFolder.exists()) {
                        fileFolder.mkdir();
                    }

                    String fileName = "err_" + nameForFile.get(i) + "_" + nameForFile.get(j);
                    final String dirSubFolder = System.getProperty("user.dir") + "/Risultati/" + fileName;
                    File fileSubFolder = new File(dirSubFolder);
                    if (!fileSubFolder.exists()) {
                        fileSubFolder.mkdir();
                    }
                    //System.out.println(fileName);
                    FileWriter writer = new FileWriter(dirSubFolder + "/" + fileName + ".csv");
                    System.out.println("\n");
                    System.out.println("*********************************************** Risultati test " + fileName + " ************************************************");
                    experiment(writer, dt, measurementNoise[i], noiseCov[j]);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }


    }

    private static void experiment(FileWriter writer, double dt, double measurementNoise, RealMatrix noiseCov) throws IOException {
        System.out.format("%5s%15s%20s%15s%20s%20s%15s%15s", "Stato", "Posizione", "PosizioneKalman", "Velocita", "VelocitaKalman", "ErrorePosizione", "ErroreVeocita", "KalmanGain");

        writer.write("Stato,Posizione,PosizioneKalman,Velocita,VelocitaKalman,ErrorePosizione, ErroreVeocita, KalmanGain");
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

        // TODO-> variare la P0 iniziale dello stato
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

        //TODO da capire-> questo genera anche dei risultati negativi per pos e vel.. è corretto? controlliamo..
        RandomGenerator rand = new JDKRandomGenerator();

        // vettore per il rumore del processo
        RealVector tmpPNoise = new ArrayRealVector(new double[]{Math.pow(dt, 2d) / 2d, dt});
        //vettore per il rumore della osservazione
        RealVector mNoise = new ArrayRealVector(1);


        //PER IL KALMAN GAIN
        RealMatrix HPH;
        RealMatrix kalmanGain;
        // matrice di covarianza dell'errore del filtro
        RealMatrix errorCovariance = filter.getErrorCovarianceMatrix();

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
            // TODO -> ma l'errore gaussiano non dovrebbe essere lo stesso per tutti gli esperimenti?
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

            risultati(writer, i, x, position, velocity, kalmanGain);

        }
        writer.flush();
        writer.close();
    }

    private static void risultati(FileWriter writer, int i, RealVector x, double position, double velocity, RealMatrix k_gain) throws IOException {
        System.out.println();
        System.out.format("%5d%15f%20f%15f%20f%20f%15f%15f", i, x.getEntry(0), position, x.getEntry(1), velocity, Math.abs(x.getEntry(0) - position), Math.abs(x.getEntry(1) - velocity), k_gain.getEntry(0, 0));

        writer.write("\n");
        writer.write(String.valueOf(i));
        writer.write(",");
        writer.write(String.valueOf(x.getEntry(0)));
        writer.write(",");
        writer.write(String.valueOf(position));
        writer.write(",");
        writer.write(String.valueOf(x.getEntry(1)));
        writer.write(",");
        writer.write(String.valueOf(velocity));
        writer.write(",");
        writer.write(String.valueOf(Math.abs(x.getEntry(0) - position)));
        writer.write(",");
        writer.write(String.valueOf(Math.abs(x.getEntry(1) - velocity)));
        writer.write(",");
        writer.write(String.valueOf(k_gain.getEntry(0, 0)));

    }

    /*private void printMatrix(RealMatrix M) {
        System.out.println("\nM:");
        for (int i = 0; i < M.getRowDimension(); i++) {
            for (int j = 0; j < M.getColumnDimension(); j++) {
                System.out.print(M.getEntry(i, j) + " ");
            }
            System.out.print("\n");
        }
    }*/
}
