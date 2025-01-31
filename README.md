# vic_tools
Some scripts with useful tools for the VIC (Variable Infiltration Capacity) model (https://vic.readthedocs.io/en/master/) in La Plata Basin (LPB) region.

## Clone the repository
To clone the repository in your work station, write the following command from an OS terminal:
```
$ git clone https://github.com/Gonzalo1985/vic_tools
```

## Calibration
The **Calibration** subfolder contains the files to generate calibration of the VIC model by watershed. To download the **.bash** enter to each file and click on *'Copy raw contents'* to make a copy of the code or work with the files directly cloned in your work station.

## InWshed
The **InWshed** subfolder contains the files for the application that finds the contribution points of a watershed based on its closing point. You must have some output files from VIC (fluxes files) and the routing model installed in your work station. To run the process write the following command line:
```
$ ./determina-puntos-cuenca.bash -56.8125 -29.5625 PASOL
```
First the longitude and latitude of the closing point is what is indicated and then a name of the point (no more than 5 letters). In the **test** folder there are some sample output files.

## Operational
The **Operational** subfolder contains the files in bash and R language for running the model in operational mode with different databases. There is also a folder for post processing.