// =============================================================================
//  Bialetti 1-cup moka — coffee dosing / leveling helper  (single piece)
// -----------------------------------------------------------------------------
//  A cylindrical cap that slips over the OUTER RIM of the moka boiler (with the
//  filter funnel inserted) and rotates freely on it. A helical blade is fixed
//  rigidly inside: you grab the knurled body and TURN THE WHOLE TOOL on the rim.
//    * turn one way  -> the flat bottom edge of the flight levels the grounds
//                      flush with the funnel
//    * turn the other -> the broad helical face augers excess powder up and out
//  The skirt-over-rim clearance is the bearing; there is nothing to assemble.
//
//  Design goals: PRINTABILITY FIRST — prints in ONE orientation, NO supports.
//  The blade is a full-height twisted wall whose edge reaches the bed, and every
//  other face is either a vertical cylinder wall or an up-facing shoulder.
//
//  Dimensions below are MEASURED for a specific pot; tune the [Moka fit] block.
// =============================================================================

/* [What to render] */
// print  = ready-to-slice orientation (default)
// model  = functional orientation (as it sits on the pot)
// section = cutaway of the functional model
part = "print";

/* [Moka fit — MEASURED] */
boiler_top_d = 51.0;   // outer diameter of the boiler top the helper slips over
funnel_rim_d = 45.0;   // filter-funnel rim diameter (the coffee-level circle)

/* [Fit & print tolerances] */
rim_clr = 1.40;   // slip/rotate clearance on the rim (test print too snug: +1mm on Ø)
clr     = 0.40;   // general print clearance (pour-cup bore / blade sweep gap)
wall    = 2.40;   // wall thickness

/* [Proportions] */
skirt_h  = 10.0;   // depth the skirt grips down over the boiler rim
cup_h    = 12.0;   // height of the upper pour cup / blade section

/* [Blade — helical scoop screw] */
blade_w     = 3.4;    // tangential thickness of the flight ribbon (+0.4mm: was too thin)
blade_twist = 160;    // degrees of helix over cup_h. FEWER deg = steeper pitch + better self-support
hub_r       = 4.5;    // central hub radius (blade roots here; pour around it)
blade_root  = 1.5;    // how far the blade inner edge reaches INTO the hub (secure weld)
grip_teeth  = 30;     // knurl teeth around the body for grip

/* [Quality] */
$fn = 160;

// -----------------------------------------------------------------------------
//  Derived geometry  (datum: screed plane z = 0 = boiler-rim / coffee level)
// -----------------------------------------------------------------------------
skirt_bore = boiler_top_d + rim_clr;      // slips over & rotates on the rim
body_od    = skirt_bore + 2*wall;
funnel_r   = funnel_rim_d/2;
cup_ir     = funnel_r + clr;              // upper pour-cup bore (leaves funnel open)
blade_or   = cup_ir;                      // flight welds into the cup wall
eps = 0.02;

// The shoulder between cup_ir and skirt_bore/2 (at z=0) is what the boiler rim
// butts up against, setting how deep the tool seats:
//   skirt_bore/2 = 25.7  >  cup_ir = 22.9  ->  ~2.8 mm seating shoulder.

// -----------------------------------------------------------------------------
//  One helical flight (auger vane): a radial ribbon extruded up with twist.
//  Flat bottom edge on the screed plane levels the grounds; the broad helical
//  face augers excess up. Full height so its edge reaches the bed when printed.
// -----------------------------------------------------------------------------
module blade() {
    // Inner edge starts blade_root INSIDE the hub so the ribbon is embedded in
    // the tower (a solid weld) rather than merely touching its surface.
    inner_r = hub_r - blade_root;
    linear_extrude(height = cup_h, twist = blade_twist, slices = 80, convexity = 10)
        translate([inner_r, -blade_w/2])
            square([blade_or - inner_r, blade_w]);
}

// =============================================================================
//  HELPER  (single piece)
// =============================================================================
module helper() {
    union() {
        difference() {
            // full outer body: skirt below the screed plane, pour cup above
            translate([0,0,-skirt_h])
                cylinder(h = skirt_h + cup_h, d = body_od);

            // skirt bore — slips over / rotates on the boiler rim (open bottom)
            translate([0,0,-skirt_h - eps])
                cylinder(h = skirt_h + eps, d = skirt_bore);

            // upper pour-cup bore — coffee funnels down through here.
            // Narrower than the skirt bore, so the ring left at z=0 is the
            // seating shoulder the boiler rim stops against.
            translate([0,0,-eps])
                cylinder(h = cup_h + 2*eps, r = cup_ir);
        }

        // central hub the flight spirals around
        cylinder(h = cup_h, r = hub_r);

        // the fixed helical blade
        blade();

        // knurl grip around the outside so you can twist the tool on the rim
        translate([0,0,-skirt_h])
        for (i = [0:grip_teeth-1])
            rotate([0,0, i*360/grip_teeth])
            translate([body_od/2 - 0.4, 0, 0])
                cylinder(h = skirt_h + cup_h, d = 1.8, $fn = 12);
    }
}

// Ready-to-print: flipped so the pour-cup opening (and the blade edge, hub, and
// cup walls) sit flat on the bed. No supports.
module helper_print() {
    translate([0,0, cup_h]) rotate([180,0,0]) helper();
}

// =============================================================================
//  Render selector
// =============================================================================
if      (part == "model")   helper();
else if (part == "section") intersection() {
                                helper();
                                translate([-200,-400,-200]) cube([400,400,400]);
                            }
else                        helper_print();   // "print"
