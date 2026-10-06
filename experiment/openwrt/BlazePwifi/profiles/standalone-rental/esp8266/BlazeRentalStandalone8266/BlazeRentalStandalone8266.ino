#define BLAZE_SLOT_COUNT 2
#include "BlazeRentalStandaloneCore.h"
BlazeRentalStandalone BlazeRentalServer;
void setup(){ BlazeRentalServer.begin(); }
void loop(){ BlazeRentalServer.loop(); }
