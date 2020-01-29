import aima.core.probability.CategoricalDistribution;
import aima.core.probability.RandomVariable;
import aima.core.probability.bayes.BayesianNetwork;
import aima.core.probability.bayes.Node;
import aima.core.probability.bayes.impl.FullCPTNode;
import aima.core.probability.domain.FiniteDomain;
import aima.core.probability.proposition.AssignmentProposition;
import bifParser.BifBNReader;

import java.io.FileWriter;
import java.io.IOException;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Random;

public class Main {

    static final String[] fileReti = new String[]{
            "asia.bif",
            "child.bif",
            "hepar2.bif",
            "pathfinder.bif",
    };

    public static void main(String... args) throws Exception {

        BayesianNetwork[] reti = new BayesianNetwork[fileReti.length];

        // Fase di lettura delle reti da file
        for(int i = 0; i < fileReti.length; i++){
            BifBNReader bnReader = new BifBNReader("src/BN/" + fileReti[i]) {
                @Override
                protected Node nodeCreation(RandomVariable var, double[] probs, Node... parents) {
                    return new FullCPTNode(var, probs, parents);
                }
            };
            reti[i] = bnReader.getBayesianNetwork();
        }

        // Istanzio il motore inferenziale
        ExactInference inference = new ExactInference();

        // Primo test: map sulle reti al variare del numero di variabii map
        // Ad ogni iterazione aumenteremo il numero di variabili MAP del 10%
        // con nessuna variabile di evidenza, quindi avremo 10 risultati per ogni rete
        /*FileWriter map_writer = new FileWriter("map_test.csv");
        map_writer.write("Rete,Nodi,Variabili MAP,MAP Value,Tempo\n");
        System.out.println("Rete,Nodi,Variabili MAP,MAP Value,Tempo\n");
        map_test(reti, inference, map_writer);
        map_writer.flush();
        map_writer.close();*/

        // Secondo test: mpe sulle reti al variare del numero di variabili di evidenza.
        // Ad ogni iterazione aumenteremo il numero di variabili evidenza del 10% impostate
        // a valori casuali. Anche qui avremo 10 risultati per ogni rete.
        /*FileWriter mpe_writer = new FileWriter("mpe_test.csv");
        mpe_writer.write("Rete,Nodi,Variabili Evidenza,MPE Value,Tempo\n");
        System.out.println("Rete,Nodi,Variabili Evidenza,MPE Value,Tempo\n");
        mpe_test(reti, inference, mpe_writer);
        mpe_writer.flush();
        mpe_writer.close();*/

        // Terzo test: map ed mpe sulle reti a confronto, al variare del numero di variabili di evidenza.
        // Le variabili map saranno sempre impostate al 50% del totale delle variabili della rete, mentre
        // il totale di variabili di evidenza andrà aumentando dal 10% al 90%
        FileWriter mpe_map_writer = new FileWriter("mpe_map_test.csv");
        mpe_map_writer.write("Rete,Nodi,Variabili Evidenza,Tempo MAP,Tempo MPE\n");
        System.out.println("Rete,Nodi,Variabili Evidenza,Tempo MAP,Tempo MPE\n");
        mpe_map_test(reti[2], inference, mpe_map_writer, 2);
        mpe_map_test(reti[3], inference, mpe_map_writer, 3);
        mpe_map_writer.flush();
        mpe_map_writer.close();
    }

    public static void map_test(BayesianNetwork[] reti, ExactInference inference, FileWriter file) throws IOException {

        for(int i = 0; i < reti.length; i++){
            BayesianNetwork rete = reti[i];
            ArrayList<RandomVariable> allVars = new ArrayList<>(rete.getVariablesInTopologicalOrder());

            for(int j = 0; j < 10; j++){

                int num_map_vars = (allVars.size() * j) / 10;
                RandomVariable[] map_vars= new RandomVariable[num_map_vars];

                for(int y = 0; y < num_map_vars; y++){
                    // Prendo le prime num_map_vars in ordine topologico: provando a prenderle in ordine casuale,
                    // l'algoritmo esaurisce la memoria con reti superiori ai 50 nodi.
                    map_vars[y] = allVars.get(y);
                }

                Instant start = Instant.now();
                CategoricalDistribution map = inference.map(map_vars, new AssignmentProposition[]{}, rete);
                long tempo_map = Duration.between(start, Instant.now()).toMillis();
                float map_value = Float.parseFloat(map.toString()
                        .replace("<", "")
                        .replace(">", ""));

                file.write(fileReti[i].replace(".bif", "") + ",");
                System.out.print(fileReti[i].replace(".bif", "") + ",");
                file.write(rete.getVariablesInTopologicalOrder().size() + ",");
                System.out.print(rete.getVariablesInTopologicalOrder().size() + ",");
                file.write(num_map_vars + ",");
                System.out.print(num_map_vars + ",");
                file.write(map_value + ",");
                System.out.print(map_value + ",");
                file.write(tempo_map + "\n");
                System.out.print(tempo_map + "\n");

            }
        }
    }

    private static void mpe_test(BayesianNetwork[] reti, ExactInference inference, FileWriter file) throws IOException {

        for(int i = 0; i < reti.length; i++){
            BayesianNetwork rete = reti[i];
            ArrayList<RandomVariable> allVars =  new ArrayList<>(rete.getVariablesInTopologicalOrder());
            Collections.reverse(allVars);

            for(int j = 0; j < 10; j++){

                int num_ev_vars = (allVars.size() * j) / 10;
                AssignmentProposition[] ass = new AssignmentProposition[num_ev_vars];

                for(int y = 0; y < ass.length; y++){
                    FiniteDomain domain = (FiniteDomain) allVars.get(y).getDomain();
                    ass[y] = new AssignmentProposition(allVars.get(y), domain.getValueAt(new Random().nextInt(domain.size())));
                }

                Instant start = Instant.now();
                CategoricalDistribution mpe = inference.mpe(ass, rete);
                long tempo_mpe = Duration.between(start, Instant.now()).toMillis();
                float mpe_value = Float.parseFloat(mpe.toString()
                        .replace("<", "")
                        .replace(">", ""));

                file.write(fileReti[i].replace(".bif", "") + ",");
                System.out.print(fileReti[i].replace(".bif", "") + ",");
                file.write(rete.getVariablesInTopologicalOrder().size() + ",");
                System.out.print(rete.getVariablesInTopologicalOrder().size() + ",");
                file.write(num_ev_vars + ",");
                System.out.print(num_ev_vars + ",");
                file.write(mpe_value + ",");
                System.out.print(mpe_value + ",");
                file.write(tempo_mpe + "\n");
                System.out.print(tempo_mpe + "\n");

            }
        }
    }

    /*private static void mpe_map_test(BayesianNetwork[] reti, ExactInference inference, FileWriter file) throws IOException {

        for(int i = 0; i < reti.length; i++){
            BayesianNetwork rete = reti[i];
            ArrayList<RandomVariable> allVars = new ArrayList<>(rete.getVariablesInTopologicalOrder());

            // In questo test, per ogni rete saranno impostate come variabili MAP la metà delle variabili della rete
            RandomVariable[] map_vars= new RandomVariable[allVars.size()/2];
            for(int y = 0; y < (allVars.size()/2); y++){
                // Prendo le prime num_map_vars in ordine topologico: provando a prenderle in ordine casuale,
                // l'algoritmo esaurisce la memoria con reti superiori ai 50 nodi.
                map_vars[y] = allVars.get(y);
            }

            // Cambio l'ordine per far si che le evidenze vengano prese dal basso verso l'alto
            Collections.reverse(allVars);

            for(int j = 0; j < 9; j++){

                // Definiamo gli assegnamenti che useremo sia per MAP che per MPE
                int num_ev_vars = (allVars.size() * (j + 1) / 10);
                AssignmentProposition[] ass = new AssignmentProposition[num_ev_vars];
                for(int y = 0; y < ass.length; y++){
                    FiniteDomain domain = (FiniteDomain) allVars.get(y).getDomain();
                    ass[y] = new AssignmentProposition(allVars.get(y), domain.getValueAt(new Random().nextInt(domain.size())));
                }

                Instant start_map = Instant.now();
                CategoricalDistribution map = inference.map(map_vars, ass, rete);
                float tempo_map = Duration.between(start_map, Instant.now()).toMillis();

                Instant start_mpe = Instant.now();
                CategoricalDistribution mpe = inference.mpe(ass, rete);
                float tempo_mpe = Duration.between(start_mpe, Instant.now()).toMillis();


                file.write(fileReti[i].replace(".bif", "") + ",");
                System.out.print(fileReti[i].replace(".bif", "") + ",");
                file.write(rete.getVariablesInTopologicalOrder().size() + ",");
                System.out.print(rete.getVariablesInTopologicalOrder().size() + ",");
                file.write(num_ev_vars + ",");
                System.out.print(num_ev_vars + ",");
                file.write(tempo_map + ",");
                System.out.print(tempo_map + ",");
                file.write(tempo_mpe + "\n");
                System.out.print(tempo_mpe + "\n");
            }
        }
    }*/

    private static void mpe_map_test(BayesianNetwork rete, ExactInference inference, FileWriter file, int f) throws IOException {

        ArrayList<RandomVariable> allVars = new ArrayList<>(rete.getVariablesInTopologicalOrder());

        // In questo test, per ogni rete saranno impostate come variabili MAP la metà delle variabili della rete
        int num_map_vars = allVars.size() / 2;
        RandomVariable[] map_vars= new RandomVariable[num_map_vars];
        for(int y = 0; y < num_map_vars; y++){
            // Prendo le prime num_map_vars in ordine topologico: provando a prenderle in ordine casuale,
            // l'algoritmo esaurisce la memoria con reti superiori ai 50 nodi.
            map_vars[y] = allVars.get(y);
        }

        // Cambio l'ordine per far si che le evidenze vengano prese dal basso verso l'alto
        Collections.reverse(allVars);

        for(int j = 1; j <= 20; j++){

            // Definiamo gli assegnamenti che useremo sia per MAP che per MPE
            int num_ev_vars = j;
            AssignmentProposition[] ass = new AssignmentProposition[0];
            for(int y = 0; y < ass.length; y++){
                FiniteDomain domain = (FiniteDomain) allVars.get(y).getDomain();
                ass[y] = new AssignmentProposition(allVars.get(y), domain.getValueAt(new Random().nextInt(domain.size())));
            }

            Instant start_map = Instant.now();
            CategoricalDistribution map = inference.map(map_vars, ass, rete);
            long tempo_map = Duration.between(start_map, Instant.now()).toMillis();

            Instant start_mpe = Instant.now();
            CategoricalDistribution mpe = inference.mpe(ass, rete);
            long tempo_mpe = Duration.between(start_mpe, Instant.now()).toMillis();


            file.write(fileReti[f].replace(".bif", "") + ",");
            System.out.print(fileReti[f].replace(".bif", "") + ",");
            file.write(rete.getVariablesInTopologicalOrder().size() + ",");
            System.out.print(rete.getVariablesInTopologicalOrder().size() + ",");
            file.write(num_ev_vars + ",");
            System.out.print(num_ev_vars + ",");
            file.write(tempo_mpe + ",");
            System.out.print(tempo_mpe + ",");
            file.write(tempo_map + "\n");
            System.out.print(tempo_map + "\n");

        }
    }
}