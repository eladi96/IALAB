import aima.core.probability.CategoricalDistribution;
import aima.core.probability.RandomVariable;
import aima.core.probability.bayes.BayesNetExampleFactory;
import aima.core.probability.bayes.BayesianNetwork;
import aima.core.probability.proposition.AssignmentProposition;

import java.util.List;

public class main {

    public static void main(String... args){
        BayesianNetwork burglary_bn = BayesNetExampleFactory.constructBurglaryAlarmNetwork();
        List<RandomVariable> allrv = burglary_bn.getVariablesInTopologicalOrder();
        System.out.println(allrv);

        ExactInference inference = new ExactInference();

        CategoricalDistribution result = inference.map(new RandomVariable[]{allrv.get(0), allrv.get(1), allrv.get(3), allrv.get(4)}, new AssignmentProposition[]{},
                burglary_bn);
        System.out.println(result);
    }
}
