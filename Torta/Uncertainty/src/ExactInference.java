import aima.core.probability.CategoricalDistribution;
import aima.core.probability.Factor;
import aima.core.probability.RandomVariable;
import aima.core.probability.bayes.BayesianNetwork;
import aima.core.probability.bayes.FiniteNode;
import aima.core.probability.bayes.Node;
import aima.core.probability.proposition.AssignmentProposition;
import aima.core.probability.util.ProbabilityTable;

import java.util.*;

public class ExactInference {

    public CategoricalDistribution mpe(final AssignmentProposition[] e, final BayesianNetwork bn) {

        // In VARS abbiamo tutte le variabili della rete in ordine inverso a quello topologico (dal basso verso l'alto)
        List<RandomVariable> VARS = reverse(bn.getVariablesInTopologicalOrder());
        // In hidden avremo tutte le variabili che non sono parte dell'evidenza
        Set<RandomVariable> hidden = new HashSet<>();
        for (RandomVariable var : VARS) {
            if ((!Arrays.asList(e).contains(var)))
                hidden.add(var);
        }

        // In questo ciclo costruiamo per ogni variabile il fattore corrispondente, ed effetuiamo il maxout quando
        // incontriamo una variabile hidden
        List<Factor> factors = new ArrayList<Factor>();
        for (RandomVariable var : VARS) {
            factors.add(0, makeFactor(var, e, bn));
            if (hidden.contains(var)) {
                factors = maxOut(var, factors, bn);
            }
        }

        // Prodotto pointwise tra i fattori rimasti (se è solo un fattore ritorna se stesso)
        ProbabilityTable product = (ProbabilityTable) pointwiseProduct(factors);
        return product;
    }


    public CategoricalDistribution map(final RandomVariable[] map_var,
                                       final AssignmentProposition[] e, final BayesianNetwork bn) {

        // In VARS abbiamo tutte le variabili della rete in ordine inverso a quello topologico (dal basso verso l'alto)
        List<RandomVariable> VARS = new ArrayList<RandomVariable>(bn.getVariablesInTopologicalOrder());
        // Popoliamo la lista delle variabili non map
        Set<RandomVariable> non_map = new HashSet<RandomVariable>();
        for (RandomVariable var : VARS) {
            //if ((!Arrays.asList(map_var).contains(var) && !Arrays.asList(e).contains(var)))
            if (!Arrays.asList(map_var).contains(var))
                non_map.add(var);
        }

        // Costruiamo i fattori di tutte le variabili
        List<Factor> factors = new ArrayList<Factor>();
        for (RandomVariable var : reverse(VARS)) {
            factors.add(0, makeFactor(var, e, bn));
            if (non_map.contains(var)) {
                factors = sumOut(var, factors, bn);
            }
        }

        // Effettuiamo il sumOut delle variabili non map, ovvero viene effettuato prima il prodotto pointwise tra tutte
        // le tabelle che contengono la variabile, e poi viene effettuato il sumout sulla tabella risultante
        /*for (RandomVariable var : reverse(VARS)) {
            if (non_map.contains(var)) {
                factors = sumOut(var, factors, bn);
            }
        }*/

        // Effettuiamo il maxout delle variabii map, ovvero prima il prodotto pointwise tra tutte le tabelle che
        // contengono la variabile e poi il maxout sulla tabella risultante
        for (RandomVariable var : reverse(VARS)) {
            if (Arrays.asList(map_var).contains(var)) {
                factors = maxOut(var, factors, bn);
            }
        }

        // Prodotto pointwise tra i fattori rimasti (se è solo un fattore ritorna se stesso)
        ProbabilityTable product = (ProbabilityTable) pointwiseProduct(factors);
        return product;
    }

    private List<Factor> sumOut(RandomVariable var, List<Factor> factors,
                                BayesianNetwork bn) {
        List<Factor> summedOutFactors = new ArrayList<Factor>();
        List<Factor> toMultiply = new ArrayList<Factor>();
        for (Factor f : factors) {
            if (f.contains(var)) {
                toMultiply.add(f);
            } else {
                summedOutFactors.add(f);
            }
        }

        if (!toMultiply.isEmpty())
            summedOutFactors.add(internalSumOut((ProbabilityTable) pointwiseProduct(toMultiply), var));

        return summedOutFactors;
    }

    private Factor internalSumOut(ProbabilityTable table, RandomVariable... vars) {
        Set<RandomVariable> soutVars = new LinkedHashSet<RandomVariable>(
                table.getArgumentVariables());
        for (RandomVariable rv : vars) {
            soutVars.remove(rv);
        }
        final ProbabilityTable summedOut = new ProbabilityTable(soutVars);
        if (1 == summedOut.getValues().length) {
            summedOut.getValues()[0] = table.getSum();
        } else {
            final Object[] termValues = new Object[summedOut.getArgumentVariables()
                    .size()];
            ProbabilityTable.Iterator di = new ProbabilityTable.Iterator() {
                public void iterate(Map<RandomVariable, Object> possibleWorld,
                                    double probability) {

                    int i = 0;
                    for (RandomVariable rv : summedOut.getArgumentVariables()) {
                        termValues[i] = possibleWorld.get(rv);
                        i++;
                    }
                    summedOut.getValues()[summedOut.getIndex(termValues)] += probability;
                }
            };
            table.iterateOverTable(di);
        }

        return summedOut;
    }


    private List<Factor> maxOut(RandomVariable var, List<Factor> factors,
                                BayesianNetwork bn) {
        List<Factor> maxedOutFactors = new ArrayList<Factor>();
        List<Factor> toMultiply = new ArrayList<Factor>();
        for (Factor f : factors) {
            if (f.contains(var)) {
                toMultiply.add(f);
            } else {
                maxedOutFactors.add(f);
            }
        }

        if (!toMultiply.isEmpty())
            maxedOutFactors.add(internalMaxOut((ProbabilityTable) pointwiseProduct(toMultiply), var));

        return maxedOutFactors;
    }

    private Factor internalMaxOut(ProbabilityTable table, RandomVariable... vars) {

        Set<RandomVariable> moutVars = new LinkedHashSet<RandomVariable>(
                table.getArgumentVariables());
        for (RandomVariable rv : vars) {
            moutVars.remove(rv);
        }
        final ProbabilityTable maxedOut = new ProbabilityTable(moutVars);
        if (1 == maxedOut.getValues().length) {
            maxedOut.getValues()[0] = Math.max(table.getValues()[0], table.getValues()[1]);
        } else {
            final Object[] termValues = new Object[maxedOut.getArgumentVariables()
                    .size()];
            ProbabilityTable.Iterator di = new ProbabilityTable.Iterator() {
                public void iterate(Map<RandomVariable, Object> possibleWorld,
                                    double probability) {

                    int i = 0;
                    for (RandomVariable rv : maxedOut.getArgumentVariables()) {
                        termValues[i] = possibleWorld.get(rv);
                        i++;
                    }
                    double value = maxedOut.getValues()[maxedOut.getIndex(termValues)];
                    maxedOut.getValues()[maxedOut.getIndex(termValues)] = Math.max(value, probability);
                }
            };
            table.iterateOverTable(di);
        }

        return maxedOut;
    }

    private List<RandomVariable> reverse(Collection<RandomVariable> list) {
        List<RandomVariable> order = new ArrayList<RandomVariable>(list);
        Collections.reverse(order);
        return order;
    }

    private Factor makeFactor(RandomVariable var, AssignmentProposition[] e,
                              BayesianNetwork bn) {

        Node n = bn.getNode(var);
        if (!(n instanceof FiniteNode)) {
            throw new IllegalArgumentException(
                    "The algorithm only works with finite Nodes.");
        }
        FiniteNode fn = (FiniteNode) n;
        List<AssignmentProposition> evidence = new ArrayList<AssignmentProposition>();
        for (AssignmentProposition ap : e) {
            if (fn.getCPT().contains(ap.getTermVariable())) {
                evidence.add(ap);
            }
        }

        return fn.getCPT().getFactorFor(
                evidence.toArray(new AssignmentProposition[evidence.size()]));
    }

    private Factor pointwiseProduct(List<Factor> factors) {

        Factor product = factors.get(0);
        for (int i = 1; i < factors.size(); i++) {
            product = product.pointwiseProduct(factors.get(i));
        }

        return product;
    }
}