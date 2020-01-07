import aima.core.probability.CategoricalDistribution;
import aima.core.probability.RandomVariable;
import aima.core.probability.bayes.BayesianNetwork;
import aima.core.probability.bayes.Node;
import aima.core.probability.bayes.exact.EliminationAsk;
import aima.core.probability.bayes.impl.FullCPTNode;
import aima.core.probability.domain.FiniteDomain;
import aima.core.probability.proposition.AssignmentProposition;
import bifParser.BifBNReader;
import dnl.utils.text.table.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;

public class Main {

    public static void main(String... args) throws Exception {

        String[] file = new String[]{
                "asia.bif",
                "alarm.bif",
                "hepar2.bif",
                "pathfinder.bif"
                };
        BayesianNetwork[] reti = new BayesianNetwork[file.length];

        // Fase di lettura delle reti da file
        for(int i = 0; i < file.length; i++){
            BifBNReader bnReader = new BifBNReader("src/BN/" + file[i]) {
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
        // Per ogni BN useremo il 20, 40, 60, 80 e 100 % di variabili map, quindi
        // avremo 5 risultati per ogni rete
        Sperimentazione[][] risultati = new Sperimentazione[file.length][5];
        for(int i = 0; i < file.length; i++){
            for(int y = 0; y < 5; y++){

                Sperimentazione corrente = new Sperimentazione();
                corrente.setNomeRete(file[i]);
                corrente.setNumNodi(reti[i].getVariablesInTopologicalOrder().size());

                testMap(corrente, reti[i], inference, y);
                testMpe(corrente, reti[i], inference, y);
                risultati[i][y] = corrente;
                System.out.println(risultati[i][y].toString());
            }
        }
    }

    public static void testMap(Sperimentazione corrente, BayesianNetwork bn, ExactInference inference, int y){
        corrente.setNumMapVar(corrente.getNumNodi() * (y+1) / 5);

        RandomVariable[] mapVars = new RandomVariable[corrente.getNumMapVar()];
        ArrayList<RandomVariable> allVars = new ArrayList<>(bn.getVariablesInTopologicalOrder());
        for(int j = 0; j < mapVars.length; j++){
            mapVars[j] = allVars.get(j);
        }

        long start = System.nanoTime();
        corrente.setMapValue(Float.parseFloat(inference.map(mapVars, new AssignmentProposition[]{}, bn).toString().replace("<", "").replace(">", "")));
        corrente.setTempoMap(System.nanoTime() - start);

    }

    public static void testMpe(Sperimentazione corrente, BayesianNetwork bn, ExactInference inference, int y){
        ArrayList<RandomVariable> allVars = new ArrayList<>(bn.getVariablesInTopologicalOrder());
        Collections.reverse(allVars);
        corrente.setNumEvidenze(corrente.getNumNodi() * (y+1) / 5);
        AssignmentProposition[] ass = new AssignmentProposition[corrente.getNumEvidenze()];
        for(int j = 0; j < ass.length; j++){
            FiniteDomain domain = (FiniteDomain) allVars.get(j).getDomain();
            ass[j] = new AssignmentProposition(allVars.get(j), domain.getValueAt(new Random().nextInt(domain.size())));
        }

        long start = System.nanoTime();
        corrente.setMpeValue(Float.parseFloat(inference.mpe(ass, bn).toString().replace("<", "").replace(">", "")));
        corrente.setTempoMpe(System.nanoTime() - start);
    }
}