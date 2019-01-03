### origen_arm/cores

#### Structure

This directory contains all of the modeling of the cores themselves.

The `base_core/` directory contains the base ARM core containing all common
core functionality.

The `cortex` directory includes the cortex (cmX) core models, as well as
a base class for the CortexM-series cores.

#### Contributing

The existing cores can be updated as needed. Care needs to be taken when
updating any of the base cores, however, since it will affect all cores in
the remaining inheritance heirarchy.

New cortex m-series cores can be added to the `cortex-m` directory. New core types
(e.g., the A-series) can be created in a new directory, with their own base
class.

