#define BLAZE_SLOT_COUNT 4
#include "BlazeRentalStandaloneCore.h"
BlazeRentalStandalone BlazeRentalServer;
void setup(){ BlazeRentalServer.begin(); }
void loop(){ BlazeRentalServer.loop(); }
