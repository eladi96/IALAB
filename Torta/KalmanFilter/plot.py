import glob
import os
import matplotlib.pyplot as plt
import csv
from numpy import double
import statistics as st

pathRisultati = (os.path.join(os.getcwd(), "Risultati"))

nameFile = []


def plotVelocita():
    # posizione
    plt.clf()
    plt.plot(velX, linewidth=2)
    plt.plot(velX_K, linestyle='dashed', linewidth=2)
    plt.plot(velY, linewidth=2)
    plt.plot(velY_K, linestyle='dashed', linewidth=2)
    plt.title('Velocità')
    plt.xlabel('Stato')
    plt.legend(['VelocitàX', 'VelocitàX Kalman', 'VelocitàY', 'VelocitàY Kalman'])
    namePNG = nameFile + 'velocita.png'
    plt.savefig(os.path.join(path_sub, namePNG))
    plt.clf()


def plotPosizione():
    plt.clf()
    plt.plot(posX, linewidth=2)
    plt.plot(posX_K, linestyle='dashed', linewidth=2)
    plt.plot(posY, linewidth=2)
    plt.plot(posY_K, linestyle='dashed', linewidth=2)
    plt.title('Posizione')
    plt.xlabel('Stato')
    plt.legend(['PosizioneX', 'PosizioneX Kalman', 'PosizioneY', 'PosizioneY Kalman'])
    namePNG = nameFile + 'posizione.png'
    plt.savefig(os.path.join(path_sub, namePNG))
    plt.clf()
    plt.clf()


def plotErroreVel():
    plt.clf()
    plt.plot(errVelX, linewidth=2)
    plt.plot(errVelY, linewidth=2)
    plt.title('Errore Velocità')
    plt.xlabel('Stato')
    plt.legend(['Errore Velocità X', 'Errore Velocità Y'])
    namePNG = nameFile + 'errore_velocita.png'
    plt.savefig(os.path.join(path_sub, namePNG))
    plt.clf()


def plotErrorePos():
    plt.clf()
    plt.plot(errPosX, linewidth=2)
    plt.plot(errPosY, linewidth=2)
    plt.title('Errore Posizione')
    plt.xlabel('Stato')
    plt.legend(['Errore Posizione X', 'Errore Posizione Y'])
    namePNG = nameFile + 'errore_posizione.png'
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


if __name__ == "__main__":

    for root, dirs, _ in os.walk(pathRisultati):
        for d in dirs:
            path_sub = os.path.join(root, d)  # this is the current subfolder
            for filename in glob.glob(os.path.join(path_sub, '*.csv')):
                nameFile = os.path.basename(filename).replace('.csv', '_')
                # print(pathFile)

                state = []
                velX = []
                velX_K = []
                velY = []
                velY_K = []
                posX = []
                posX_K = []
                posY = []
                posY_K = []
                errVelX = []
                errVelY = []
                errPosX = []
                errPosY = []
                kGain = []

                with open(filename, "r") as f:

                    file = csv.reader(f, delimiter=',')
                    header = next(file)

                    for row in file:
                        state.append(int(row[0]))
                        velX.append(double(row[1]))
                        velX_K.append(double(row[2]))
                        velY.append(double(row[3]))
                        velY_K.append(double(row[4]))
                        posX.append(double(row[5]))
                        posX_K.append(double(row[6]))
                        posY.append(double(row[7]))
                        posY_K.append(double(row[8]))
                        errVelX.append(double(row[9]))
                        errVelY.append(double(row[10]))
                        errPosX.append(double(row[11]))
                        errPosY.append(double(row[12]))
                        kGain.append(double(row[13]))

                    plotPosizione()
                    plotVelocita()
                    plotErrorePos()
                    plotErroreVel()
                    plotKalmanGain()
