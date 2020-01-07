public class Sperimentazione {

    private String nomeRete;
    private int numNodi;
    private int numEvidenze;
    private int numMapVar;
    private float tempoMpe;
    private float tempoMap;
    private float mpeValue;
    private float mapValue;

    public Sperimentazione(){}

    public String getNomeRete() {
        return nomeRete;
    }

    public void setNomeRete(String nomeRete) {
        this.nomeRete = nomeRete;
    }

    public int getNumNodi() {
        return numNodi;
    }

    public void setNumNodi(int numNodi) {
        this.numNodi = numNodi;
    }

    public int getNumEvidenze() {
        return numEvidenze;
    }

    public void setNumEvidenze(int numEvidenze) {
        this.numEvidenze = numEvidenze;
    }

    public int getNumMapVar() {
        return numMapVar;
    }

    public void setNumMapVar(int numMapVar) {
        this.numMapVar = numMapVar;
    }

    public float getTempoMpe() {
        return tempoMpe;
    }

    public void setTempoMpe(float tempoMpe) {
        this.tempoMpe = tempoMpe;
    }

    public float getTempoMap() {
        return tempoMap;
    }

    public void setTempoMap(float tempoMap) {
        this.tempoMap = tempoMap;
    }

    public float getMpeValue() {
        return mpeValue;
    }

    public void setMpeValue(float mpeValue) {
        this.mpeValue = mpeValue;
    }

    public float getMapValue() {
        return mapValue;
    }

    public void setMapValue(float mapValue) {
        this.mapValue = mapValue;
    }

    public Sperimentazione(String nomeRete, int numNodi, int numEvidenze, int numMapVar, float mpeValue, float tempoMpe, float mapValue, float tempoMap) {
        this.nomeRete = nomeRete;
        this.numNodi = numNodi;
        this.numEvidenze = numEvidenze;
        this.numMapVar = numMapVar;
        this.tempoMpe = tempoMpe;
        this.tempoMap = tempoMap;
        this.mpeValue = mpeValue;
        this.mapValue = mapValue;
    }

    @Override
    public String toString() {
        return "Sperimentazione{" +
                "nomeRete='" + nomeRete + '\'' +
                ", numNodi=" + numNodi +
                ", numEvidenze=" + numEvidenze +
                ", numMapVar=" + numMapVar +
                ", tempoMpe=" + tempoMpe +
                ", tempoMap=" + tempoMap +
                ", mpeValue=" + mpeValue +
                ", mapValue=" + mapValue +
                '}';
    }
}
