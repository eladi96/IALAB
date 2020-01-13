import glob
import os
import matplotlib.pyplot as plt
import csv
from numpy import double

pathRisultati = (os.path.join(os.getcwd(), "Risultati"))

nameFile = []


def plotPosizione():
    # posizione
    plt.clf()
    plt.plot(pos)
    plt.plot(posK)
    plt.title('Posizione')
    plt.xlabel('Stato')
    plt.legend(['stimata', 'kalman'])
    namePNG = nameFile + 'posizione.png'
    plt.savefig(os.path.join(path_sub, namePNG))
    plt.clf()
    # plt.show()


def plotVelocita():
    # velocità
    plt.clf()
    plt.plot(vel)
    plt.plot(velK)
    plt.title('Velocità')
    plt.xlabel('Stato')
    plt.legend(['stimata', 'kalman'])
    namePNG = nameFile + 'velocita.png'
    plt.savefig(os.path.join(path_sub, namePNG))
    plt.clf()


def plotErrorePos():
    # ErrorePos
    plt.clf()
    plt.plot(errPos)
    plt.title('Errore Posizione')
    namePNG = nameFile + 'err_pos.png'
    plt.savefig(os.path.join(path_sub, namePNG))
    plt.clf()


def plotErroreVel():
    # ErroreVel
    plt.clf()
    plt.plot(errVel)
    plt.title('Errore Velocita')
    namePNG = nameFile + 'err_vel.png'
    plt.savefig(os.path.join(path_sub, namePNG))
    plt.clf()


def plotKalmanGain():
    # KalmanGain
    plt.clf()
    plt.plot(kGain)
    plt.xlabel('Stato')
    plt.title('Kalman Gain')
    namePNG = nameFile + 'kalmanGain.png'
    plt.savefig(os.path.join(path_sub, namePNG))
    plt.clf()


def plotErrori():
    # errore sistema vs kalman gain
    plt.clf()
    plt.plot(errPos)
    plt.plot(errVel)
    plt.plot(kGain)
    plt.legend(['posizione', 'velocita', 'kalmanGain'])
    plt.xlabel('Stato')
    plt.title('Confronto errori e gain')
    namePNG = nameFile + 'Errori e Kalman Gain.png'
    plt.savefig(os.path.join(path_sub, namePNG))
    plt.clf()


if __name__ == "__main__":

    for root, dirs, _ in os.walk(pathRisultati):
        for d in dirs:
            path_sub = os.path.join(root, d)  # this is the current subfolder
            for filename in glob.glob(os.path.join(path_sub, '*.csv')):
                nameFile = os.path.basename(filename).replace('.csv', '_')
                # print(pathFile)

                state = []
                pos = []
                posK = []
                vel = []
                velK = []
                kGain = []
                errPos = []
                errVel = []

                with open(filename, "r") as f:

                    file = csv.reader(f, delimiter=',')
                    header = next(file)

                    for row in file:
                        state.append(int(row[0]))
                        pos.append(double(row[1]))
                        posK.append(double(row[2]))
                        vel.append(double(row[3]))
                        velK.append(double(row[4]))
                        errPos.append(double(row[5]))
                        errVel.append(double(row[6]))
                        kGain.append(double(row[7]))

                    plotPosizione()
                    plotVelocita()
                    plotErrorePos()
                    plotErroreVel()
                    plotKalmanGain()
                    plotErrori()
