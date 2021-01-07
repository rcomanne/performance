# HotSpot vs OpenJ9

## How to run
### Setup
To run the tests, first execute the `build.sh` script to ensure the Docker images required are created.  
If you need to make changes in the app, all you have to do after applying the changes is running `mvn clean install` to regenerate the images.  

### Startup test
To run the startup tests, execute the `start_test.sh` script.  
This will;
- Ensure the database container is started
- Start the HotSpot container first, measuring it's resouce usage with `docker stats` and check startup time from the logs
- Shut down the Hotspot container
- Start the OpenJ9 image, measuring it's resouce usage with `docker stats` and check startup time from the logs
- Shut down the OpenJ9 container

### Load test
To run the load tests, execute the `load_test.sh` script.  
This will;
- Ensure the database container is started
- Create a new terminal window which shows `docker stats` in realtime
- Start the HotSpot container first
- Let the service generate 1000 random Ducks, 10 times, showing increase in memory for every step and the time the service thinks it took in processing.
- Retrieve the list from the database and sort it
- Delete all the ducks from the database
- Shut down the container
- Repeat for the OpenJ9 container