import pandas
import os

#controllo e inserimento path file
def insertfilename(): #continuo a richiedere il nuovo insermento finchè le informazioni non sono corrette
    try:
        filename = input('Insert the ONLY name of TEXT file: ')
        if ".txt" not in filename: #controllo se il path comprende un file di tipo testuare
            print("Error! The file must be of type '.txt'.")
            insertfilename()
        if os.path.isfile(filename): #controllo se il file esiste
            print("Error! File doesn't exists.")
            insertfilename()
    except:
        print("Error!Reinsert the name of text file please")
        insertfilename()
    return filename

#lettura del file
def reader(filename):
    with open(filename, 'r') as f:
        cur_line = ''
        while "Answer" not in cur_line: #leggo il file senza fare nulòla finche non arrivo ad Answer
            cur_line = f.readline()
        # elaboro solo i dati che rigurdano l'answer set perciò continuo a leggere solo fino a  SATISFIABLE
        while "SATISFIABLE" not in cur_line:
            cur_line = f.readline()
            cur_line = cur_line.strip() #trasformo la stringa in un array
            if "Answer" not in cur_line and "SATISFIABLE" not in cur_line and cur_line != '':
                lista = cur_line.split(" ") #splitto la stringa in array contenenti ognuno un predicato e li aggiungo
                #lista conterrà: [[lezione(profLettere2,lettere,aula5,lunedi,5,"1A")], [lezione(profLettere2,lettere,aula5,martedi,5,"1A")]

                f.close()
                lessons = [] #conterrà solo i predicati (sotto forma di stringhe) relativi alle lezioni
                lunch = []  #conterrà solo i predicati (sotto forma di stringhe) relativi alla mensa
                assignments = []  #conterrà solo i predicati (sotto forma di stringhe) relativi agli
                                 # assegnamenti materia-aula
                for elem in lista: #[lezione(profLettere2,lettere,aula5,lunedi,5,"1A")]
                    if "lezione" in elem: #vado a dividere i predicati di lezione
                        lessons.append(elem.split(","))
                    elif "va_in_mensa" in elem: #da quelli per la mensa
                        lunch.append(elem.split(","))
                    else:
                        assignments.append(elem.split(",")) #e per gli assegnamenti
                        # splitto la stringa in base alla virgola
                return [assignments, lunch, lessons] #restituisco  tutte e tre le liste come una unica

def printInfo(assignments, lunch):
    print(
        "\n\n------------------------------------------------------------- Classi che hanno diritto alla mensa: -------------------------------------------------------------")
    i = 0
    while i < len(lunch):
        info = []   #lunch[i] = [va_in_mensa("1A", fulltime)]
        for p in lunch[i]: #per ogni elemento che compone il predicato, visto come lista
            if "(" in p:
                p = p.replace("va_in_mensa(", "") #elimino il nome del predicato
            if ")" in p:
                p = p.replace(")", "") #elimino la parentesi
            if '"' in p:
                p = p.replace('"', "") #elimino il le virgolette nella classe "1A"
            info.append(p) #oggiungo ogni predicato in una lista temporanea
        lunch[i] = info #sostituisco la lista precendente con quella modificata
        # lunch[i] = ["1A", fulltime]
        i += 1
    if len(lunch) > 0: #stampo le classi che vanno in mensa
        for c in lunch:
            print(c)
    else:
        print("Nessuna classe ha il fulltime")


    #stesso procedimento per le assegnazioi dell'aula
    print("\n\n------------------------------------------------------------- Assegnameti aule: -------------------------------------------------------------")
    i = 0
    while i < len(assignments):
        info = []
        print(assignments[i])
        for p in assignments[i]:   #assignments[i] = [assegna_materia_aula(aula8, religione)]
            if "(" in p:
                p = p.replace("assegna_materia_aula(", "")
            if ")" in p:
                p = p.replace(")", "")
            if '"' in p:
                p = p.replace('"', "")
            info.append(p)
        assignments[i] = info #assignments[i] = [aula8, religione]
        i += 1
        print(assignments[i])
    if len(assignments) > 0:
        for a in assignments: #stampo le materie assegnate alle aule
            print(a)


def calendarcreator(lessons):
    classes = ["1A", "1B", "2A", "2B", "3A", "3B"]
    days = ["lunedi", "martedi", "mercoledi", "giovedi", "venerdi"]
    hours = [1, 2, 3, 4, 5, 6]
    lDict = {} #dizionario delle lezioni
    #inizializzo il dizionario
    for c in classes:
        lDict[c] = [] #key = class, value = lista di tutte le lezioni di quella classe

    # print("dic.items: \n", lDict.items())
    i = 0
    while i < len(lessons):
        info = []
        for p in lessons[i]:  #lessions[i] =[lezione(profLettere2,lettere,aula5,lunedi,5,"1A")]
            if "(" in p:
                p = p.replace("lezione(", "")
            if ")" in p:
                p = p.replace(")", "")
            if '"' in p:
                p = p.replace('"', "")
            info.append(p)
        lessons[i] = info  # ['profLettere2', 'lettere','aula5','lunedi','5','1A']

        #inizia il procedimento di suddivisione delle lezioni per classe
        c = lessons[i][5] #estraggo la classe e la uso come key del dizionario
        classlessons = lDict.get(c)  #estraggo la lista di lezioni già esistente per quella classe
        classlessons.append(info) #aggiungo la nuova lezione alla lista
        lDict[c] = classlessons #aggiorno il dizionario con il nuovo value per la classe c

        i += 1

    #creazione della calendario accademico per ogni classe in forma tabellare grazie alla librearia pandas
    for c in lDict.keys(): #per ogni classe del dizionario delle lezioni
        print("\n\n--------------------------------------------------- Calendario settimanale classe: ", c,
              "---------------------------------------------------")
        #creo un dataframe ("tabella") che abbia sulle. Le celle sono inizializzata a NAN
        dataframe = pandas.DataFrame([], index=hours, columns=days)

        # righe le 6 ore di lezione e sulle colonne i giorni.
        for l in lDict.get(c): #per ogni lezione di quella classe

            # estraggo ciò che è contenuto nella cella della tabella identificata da (ora,giorno) della lezione
            #l'ora è stata trasformata in intero
            lista = dataframe.at[int(l[4]), l[3]]
            if isinstance(lista, float): #se è NAN (è visto come un float per questo verifico il tipo)
                lista = [] #inizializzo una nuova lista e ci aggiugo un array con i dati della lezione
            lista.append([(l[1]).upper(), l[0], l[2]]) #[[LETTERE, profLettere2, aula5]]
            # aggiorno la cella della tabella con la lista delle lezioni di quell'ora e giorno
            dataframe.at[int(l[4]), l[3]] = lista
        print(dataframe.to_string()) #stampo la tabella del calendario settimanale della classe su console

        #salvataggio su un file.csv
        if not os.path.exists("../PythonScriptForASP/output"): #se non esiste la cartella output del progetto
            os.mkdir('../PythonScriptForASP/output') #la creo

        #pre ogni classe creo il proprio file.csv su cui viene salvato il proprio calendario
        dataframe.to_csv(r'../PythonScriptForASP/output/calendario_settimanale_classe_' + c + '.csv', index=None, header=True)




if __name__ == "__main__":

    filename = "../PythonScriptForASP/calendario_settimanale.txt"

    #chiedo all'utente se vuole usare il percorso di default del file in input oppure cambiarlo.
    default = input("\nDo you want to use default files? [Y|N]\n".upper()) #Y = default
    if "N" in (default).upper():
        filename = insertfilename() #leggo il nuovo path e avvio i controlli

    #avvio la lettura del file
    lista = reader(filename) #[assignments, lunch, lessons]

    #avvio la stampa gli assegnamenti materia aula e le classi che hanno diritto alla mensa
    printInfo(lista[0], lista[1]) #passa assignaments e lunch

    #avvio la creazione del calendario settimanale
    calendarcreator(lista[2]) #passa lessons
