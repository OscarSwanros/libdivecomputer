#ifndef LIBDIVECOMPUTER_BRIDGE_H
#define LIBDIVECOMPUTER_BRIDGE_H

#include <libdivecomputer/common.h>
#include <libdivecomputer/context.h>
#include <libdivecomputer/descriptor.h>
#include <libdivecomputer/device.h>
#include <libdivecomputer/parser.h>
#include <libdivecomputer/datetime.h>
#include <libdivecomputer/buffer.h>
#include <libdivecomputer/iterator.h>
#include <libdivecomputer/iostream.h>
#include <libdivecomputer/serial.h>
#include <libdivecomputer/irda.h>
#include <libdivecomputer/usb.h>
#include <libdivecomputer/usbhid.h>
#include <libdivecomputer/bluetooth.h>
#include <libdivecomputer/ble.h>
#include <libdivecomputer/units.h>

// Device-specific headers
#include <libdivecomputer/suunto_eon.h>
#include <libdivecomputer/suunto_vyper2.h>
#include <libdivecomputer/suunto_d9.h>
#include <libdivecomputer/reefnet_sensus.h>
#include <libdivecomputer/reefnet_sensuspro.h>
#include <libdivecomputer/reefnet_sensusultra.h>
#include <libdivecomputer/oceanic_atom2.h>
#include <libdivecomputer/oceanic_veo250.h>
#include <libdivecomputer/oceanic_vtpro.h>
#include <libdivecomputer/hw_ostc.h>
#include <libdivecomputer/hw_ostc3.h>
#include <libdivecomputer/hw_frog.h>
#include <libdivecomputer/atomics_cobalt.h>
#include <libdivecomputer/divesystem_idive.h>
#include <libdivecomputer/custom.h>

#endif /* LIBDIVECOMPUTER_BRIDGE_H */