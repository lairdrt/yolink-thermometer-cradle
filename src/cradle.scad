$vpt = [0, 0, 45];   // viewpoint target / translation
$fn = 64;   // finer display resolution

// YoLink Thermometer Cradle
// Stage 2: basic cradle with tapered sensor profile

// ============================================================
// SENSOR DIMENSIONS
// ============================================================

sensor_width  = 39.0;
sensor_height = 80.0;

// Depth measured from rear face

sensor_depth_top    = 24;
sensor_depth_bottom = 20;

// The front taper's knee is 26.0 mm above the sensor's bottom,
// equivalently 54.0 mm down from its top.  Measured from the
// bottom, because the bottom is the seated datum: it is where the
// sensor lands on the shelf, so the knee's height above it does
// not move if the overall height is ever re-measured.

taper_height = 26.0;   // above the sensor bottom


// ============================================================
// FIT / CRADLE DIMENSIONS
// ============================================================

side_clearance  = 0.6;
depth_clearance = 0.6;

back_wall   = 8.0;
side_wall   = 3.0;
bottom_wall = 3.0;


// ============================================================
// FRONT RETENTION
//
// Two continuous vertical rails (one per side, integral with
// its side wall), one bottom front lip, and one top front header
// rail.  All of it is derived from the side profile's front edge,
// so it follows the sensor's changing front depth automatically.
// ============================================================

// How far each rail overlaps the sensor's front face, in X
rail_face_overlap = 2.5;

// How far the rails stand forward of the sensor front, in Y
rail_thickness    = 2.0;

// Bottom front lip.  Its forward projection is rail_thickness, so
// its front face is flush with the rails' and never stands proud.
front_lip_height    = 7.0;   // how far up the lip reaches in Z

// Top front header rail: the lip's counterpart across the top of
// the front opening, flush with the cradle's rim.  Same band, same
// forward projection and same full width as the lip, so the two
// read as a pair.
//
// It does not obstruct the open top.  Like the lip, it retains by
// standing in FRONT of the sensor rather than over it: the band
// lies at front_depth_at(z), which is depth_clearance ahead of the
// sensor's front face, while the sensor drops in through the
// aperture behind it.  The cradle's front edge is parallel to the
// sensor's own taper, so that gap is depth_clearance at every
// height of the travel, not just when seated.
front_header_height = front_lip_height;   // matched to the lip


// ============================================================
// WALL MOUNTING
//
// Two #6 x 1-1/2" pan-head sheet-metal screws, vertically
// aligned on the centreline, with Everbilt 800422 #6 flat
// washers (9.525 mm OD) captured in recesses counterbored into
// the FRONT face of the rear wall, so both are driven through
// the cradle's open front.
//
// No screw-head height is assumed.  The rear wall is budgeted
// as a stack instead:
//
//   back_wall 8.0 = 3.0  solid material behind the counterbore
//                 + 3.0  washer + screw-head allowance
//                 + 2.0  clearance from hardware to the sensor
//
// so the counterbore is 3.0 + 2.0 = 5.0 deep, and the material
// left behind it is back_wall - 5.0 = 3.0.  Hardware taller than
// the 3.0 mm allowance eats into the 2.0 mm of clearance rather
// than into the sensor.
// ============================================================

screw_shank_diameter   = 3.9;    // #6 shank 3.5 mm + clearance
washer_recess_diameter = 10.75;  // washer OD 9.525 + clearance

hardware_allowance = 3.0;        // washer + screw head, budgeted not measured
hardware_clearance = 2.0;        // hardware front face to sensor rear plane

washer_recess_depth = hardware_allowance + hardware_clearance;   // 5.0

// The upper screw mirrors the lower one: as far below the top as
// the lower is above the bottom.  upper_screw_z is derived from
// this below, once outer_height is known.
lower_screw_z = 20;


// ============================================================
// EXTERIOR EDGE ROUNDING
//
// Target: about 0.75 mm radius on the exposed exterior edges, to
// kill sharp printed arrises without moving any fitting surface.
//
// Every piece of this cradle is an extrusion along X of some
// (depth, height) profile, and those profiles nest, so the
// rounding is done in two cheap passes rather than with a
// whole-body minkowski():
//
//   1. Edges that RUN ALONG X - the top rim, the bottom and rear
//      perimeters, the front faces, the taper kink - are rounded
//      by a 2D morphological opening of each slab profile:
//      offset(+r) offset(-r), intersected back with the profile.
//      A true opening is always a SUBSET of its input, so it can
//      only ever remove material; no clearance can shrink and the
//      dummy sensor cannot be newly touched.  The intersection is
//      what makes that true of this one: offset() approximates
//      its disc with a round_fn-gon, and at a CONCAVE corner the
//      pair overshoots the corner by about
//      r * (sec(180/round_fn) - 1) - 0.0147 mm at r = 0.75, which
//      is 0.0147 mm of material standing in the sensor seat.
//      Small, but it is on a fit surface, and the subset property
//      is what the rest of this reasoning rests on.
//
//   2. Edges that LIE IN the X = 0 and X = outer_width planes -
//      the four long vertical corners, plus the top, bottom,
//      front and rear edges of the outer side faces - are rounded
//      by extruding the outermost slab through a short stack of
//      progressively inset slices following a true quarter round.
//      Eight slices hold the stair within 0.075 mm of the real
//      arc, well under a print layer, so it is a 0.75 mm round for
//      any practical purpose.  The slices are unioned rather than
//      hull()ed, because hull() would fill in the non-convex
//      profile.
//
// Deliberately NOT rounded: the screw shank hole and washer
// counterbore (hardware fit), the side-wall inner faces at
// X = side_wall (the 0.6 mm side clearance), the rail inner faces
// at X = rail_width (the 2.5 mm face overlap that does the
// retaining), and the bottom sensor seat - its corners are
// concave, and an opening leaves concave corners sharp.
// ============================================================

edge_round  = 0.75;
round_steps = 8;    // slices approximating each quarter round
round_fn    = 16;   // arc resolution for the small 2D rounds


// ============================================================
// SIDE WINDOWS
//
// One rounded window per side wall, for airflow and material
// reduction, centred on the SENSOR's height rather than on the
// cradle's outer height.
//
// Sensor side area, from the sensor's own tapered profile:
//
//   (20 + 24)/2 * 26  +  24 * 54  =  572 + 1296  =  1868 mm2
//
// The window is not a rectangle, and it is not a parallelogram
// either: its two long edges answer to different things.
//
//   FRONT edge - follows the cradle's own front edge, off the same
//     front_depth_at() curve the side walls and rails use, so it
//     stays window_front_gap behind that edge at every height:
//     vertical above the knee, parallel to the taper below it.
//
//   REAR edge - straight in Y and Z, parallel to the rear wall, at
//     the fixed depth window_rear_y.  Deliberately NOT derived
//     from the front taper: the rear wall does not move, so there
//     is no reason for the web behind the window to vary, and a
//     sheared rear edge only crowds that wall at the window's
//     lowest point.
//
// The window is therefore wider at the top and narrows through the
// knee region, 17.5 mm above the taper down to 15.5 mm at its
// bottom edge.  That asymmetry is the point: it is the cradle
// tapering in, not the window being pulled in.
//
// window_depth is the window's Y depth in the upper, vertical
// section.  window_front_gap is the web between the window and the
// side profile's front edge, constant at every height - the rails
// stand a further rail_thickness forward of it, so there is about
// 4.0 mm of material ahead of the window once the edge_round rim
// flare is counted.  The web behind is constant too, at
// window_rear_y - back_wall = 4.3 mm, 3.55 after the flare.
//
// Window outline 918.3 mm2 nominal = 49.2 % of the side area
// (measured off the rendered outline: 919.8 mm2).  The area is
// within 1.5 % of the 88 mm model's window; the percentage rises
// because the sensor itself is shorter.
// ============================================================

window_depth     = 17.5;   // in Y, measured horizontally
window_height    = 54.0;   // in Z
window_corner    = 4.0;    // corner radius
window_front_gap = 2.8;    // web between window and the front face


// ============================================================
// FLOOR DRAINS
//
// Four vertical drain holes through the bottom wall, one near each
// corner of the pocket floor.  Drainage only - not mounting.
//
// The floor is the rectangle the sensor stands on: between the
// side walls' inner faces in X, and from the rear wall's front face
// to the front lip's rear face in Y.  At floor level that lip face
// is front_depth_bottom - the taper only starts above the floor -
// so the front pair needs no offset of its own, and front and rear
// share one inset, mirror images about the floor's mid-depth.
//
// drain_hole_ligament is the solid floor left between each hole's
// edge and the nearest wall.  Neither the holes nor their rims are
// rounded, like the screw holes.
//
// The seated sensor covers every one of them.  Its 39.0 x 20.0
// footprint leaves only the 0.6 side and front clearance strips of
// the floor open and none at the rear, so a hole would have to sit
// within a radius of those strips - about 0.5 of floor to the wall
// - to be even partly exposed.  The ligament wins.  The sensor
// rests on the floor rather than sealing to it, so water coming
// down the clearance gaps reaches a hole by running some 2 mm
// under the sensor's edge.
// ============================================================

drain_hole_diameter = 3.0;
drain_hole_ligament = 2.5;   // floor between each hole and the nearest wall


// ============================================================
// DERIVED DIMENSIONS
// ============================================================

inner_width = sensor_width + 2 * side_clearance;

outer_width = inner_width + 2 * side_wall;

sensor_top_depth =
    sensor_depth_top + depth_clearance;

sensor_bottom_depth =
    sensor_depth_bottom + depth_clearance;

outer_height =
    sensor_height + bottom_wall + 2;

// Depth of the front edge of the side profile, at the bottom
// and above the taper.  Shared by the side walls and by all of
// the front retaining geometry.
front_depth_bottom = back_wall + sensor_bottom_depth;
front_depth_top    = back_wall + sensor_top_depth;

// Height at which the front taper ends
taper_top_z = bottom_wall + taper_height;

// Rail width in X: side wall + side clearance + face overlap
rail_width = side_wall + side_clearance + rail_face_overlap;

// Rear-wall material left behind the recessed hardware
mount_barrier = back_wall - washer_recess_depth;

// Upper screw: same distance from the top as the lower is from the
// bottom.
upper_screw_z = outer_height - lower_screw_z;

// Window placement.  Centred on the sensor, not on the cradle.
window_center_z = bottom_wall + sensor_height / 2;
window_z_lo     = window_center_z - window_height / 2;
window_z_hi     = window_z_lo + window_height;

// The straight rear edge.  Fixed by window_depth being the depth
// of the upper, vertical section, where the front edge sits at
// front_depth_top - window_front_gap.
window_rear_y = front_depth_top - window_front_gap - window_depth;

// Floor drain centres, inset from the pocket floor's four corners.
drain_inset = drain_hole_ligament + drain_hole_diameter / 2;
drain_x     = [side_wall + drain_inset, outer_width - side_wall - drain_inset];
drain_y     = [back_wall + drain_inset, front_depth_bottom - drain_inset];


// ============================================================
// SIDE PROFILE
//
// Coordinates here are:
//   X = depth
//   Y = height
//
// Rear of cradle is at depth 0.
// Sensor rear surface begins after back_wall.
// ============================================================

module side_profile() {

    polygon([
        [0, 0],

        // bottom front
        [front_depth_bottom, 0],

        // start of taper — at the sensor's own bottom, so the front
        // edge runs parallel to the sensor's taper
        [front_depth_bottom, bottom_wall],

        // end of taper
        [front_depth_top, taper_top_z],

        // upper front
        [front_depth_top, outer_height],

        // upper rear
        [0, outer_height]
    ]);
}


// ============================================================
// EXTRUSION HELPERS
// ============================================================

// Extrude any (depth, height) profile across a width in X
module profile_extrude(width) {
    rotate([90, 0, 90])
        linear_extrude(height = width)
            children();
}


// Slices approximating a quarter round of radius r, each as
// [start depth, end depth, pull-back from the nominal outline].
//
// Slice boundaries are spaced by equal ANGLE, not equal depth: the
// arc is near-vertical where it meets the face, so equal-depth
// spacing would put a 0.3 mm riser in the first step.  Each slice
// then takes the pull-back at its own mid-angle, which centres the
// error instead of always cutting to the deeper side.  Together
// those two choices hold the stair within 0.05 mm of the true arc,
// a quarter of a print layer, at eight slices.
function quarter_round(r, steps) =
    [for (i = [0 : steps - 1])
        [r * (1 - cos(90 * i / steps)),
         r * (1 - cos(90 * (i + 1) / steps)),
         r * (1 - sin(90 * (i + 0.5) / steps))]];


// Extrude a profile across a width in X, with the end at x = 0
// rounded over radius r.  Every pull-back is positive, so the
// result stays a subset of the unrounded slab and no clearance can
// shrink.
module profile_extrude_round_start(width, r, steps = round_steps) {

    translate([r, 0, 0])
        profile_extrude(width - r)
            children();

    for (s = quarter_round(r, steps))
        translate([s[0], 0, 0])
            profile_extrude(s[1] - s[0] + 0.01)
                offset(r = -s[2], $fn = round_fn)
                    children();
}


// One flared mouth for a cut: material is taken away in a
// widening quarter round from depth r up to the face at x = 0, and
// at full flare beyond it, so the rim left behind carries a round
// of radius r.  Flares toward -X.
module cut_mouth(r, over, steps = round_steps) {

    for (s = quarter_round(r, steps))
        translate([s[0], 0, 0])
            profile_extrude(s[1] - s[0] + 0.01)
                offset(r = s[2], $fn = round_fn)
                    children();

    translate([-over, 0, 0])
        profile_extrude(over + 0.01)
            offset(r = r, $fn = round_fn)
                children();
}


// A cut straight through a wall of thickness t along X, with both
// mouths flared so neither rim is left sharp.
module flared_cut(t, r, over = 1.0) {

    translate([r, 0, 0])
        profile_extrude(t - 2 * r)
            children();

    cut_mouth(r, over) children();

    translate([t, 0, 0])
        scale([-1, 1, 1])
            cut_mouth(r, over) children();
}


// Round the convex corners of a 2D profile by r, leaving concave
// corners sharp and the profile otherwise where it was.  This is a
// morphological opening, so the result is a subset of the input -
// and the intersection is there to hold it to that, because the
// polygonal disc offset() actually uses overshoots concave
// corners by a few microns.
module rounded_2d(r) {
    intersection() {
        offset(r = r, $fn = round_fn)
            offset(r = -r, $fn = round_fn)
                children();
        children();
    }
}


// Mirror a child about the cradle's X centre plane
module mirror_x() {
    translate([outer_width, 0, 0])
        mirror([1, 0, 0])
            children();
}


// ============================================================
// SLAB PROFILES
//
// The cradle is three nested (depth, height) profiles, each
// extruded across a different width in X:
//
//   core - rear wall + bottom shelf + front lip, full width
//   rail - core + the full-height front band, out to rail_width
//   side - rail + the side profile itself, out to side_wall
//
// core is a subset of rail, and rail of side, so each inner slab
// can start just inside the next one out and nothing is lost.
// Working in merged profiles rather than per-part keeps the
// exterior rounding from leaving notches where parts used to be
// welded together along coincident faces.
// ============================================================

module core_profile() {

    union() {
        // Rear mounting wall
        square([back_wall, outer_height]);

        // Bottom shelf — carried forward to the front lip face so
        // the lip is fused to it over the shelf's full thickness.
        // This is all below the sensor, so nothing is obstructed.
        square([front_depth_at(bottom_wall) + rail_thickness, bottom_wall]);

        // Bottom front lip
        front_band(0, front_lip_height, rail_thickness);

        // Top front header rail.  Being part of the full-width core
        // slab it spans the whole front, and because it shares the
        // rails' Y band it fuses into both of them where they
        // overlap in X, bridging the opening between them.
        front_band(outer_height - front_header_height,
                   outer_height, rail_thickness);
    }
}


module rail_slab_profile() {

    union() {
        core_profile();

        // Full-height front retaining band
        front_band(0, outer_height, rail_thickness);
    }
}


module side_slab_profile() {

    union() {
        rail_slab_profile();
        side_profile();
    }
}


// ============================================================
// CRADLE
// ============================================================

// Inner slabs start this far inside the next one out, so no two
// slabs meet on a coincident plane and the outer slab's rounded
// end face is never poked through from behind.
slab_weld = 0.01;


module cradle() {

    union() {

        // Core, spanning everything between the two side walls
        translate([side_wall - slab_weld, 0, 0])
            profile_extrude(outer_width - 2 * (side_wall - slab_weld))
                rounded_2d(edge_round)
                    core_profile();

        // Rail slabs
        rail_slab();
        mirror_x() rail_slab();

        // Side walls, with their outer faces rounded
        side_slab();
        mirror_x() side_slab();
    }
}


module rail_slab() {

    translate([side_wall - slab_weld, 0, 0])
        profile_extrude(rail_width - side_wall + slab_weld)
            rounded_2d(edge_round)
                rail_slab_profile();
}


module side_slab() {

    profile_extrude_round_start(side_wall, edge_round)
        rounded_2d(edge_round)
            side_slab_profile();
}


// ============================================================
// FRONT RETENTION GEOMETRY
// ============================================================

// Depth of the side profile's front edge at height z.
// This is the same curve the side walls already follow, so it
// tracks the sensor's sloped lower front and vertical upper front.
function front_depth_at(z) =
    (z >= taper_top_z)
        ? front_depth_top
    : (z <= bottom_wall)
        ? front_depth_bottom
        : front_depth_bottom
          + (front_depth_top - front_depth_bottom)
            * (z - bottom_wall) / taper_height;


// Heights needed to describe the front edge between z_lo and z_hi
function front_edge_levels(z_lo, z_hi) =
    concat(
        [z_lo],
        [for (zb = [bottom_wall, taper_top_z]) if (zb > z_lo && zb < z_hi) zb],
        [z_hi]
    );


// A (depth, height) band hugging the front edge: its rear face is
// the front edge itself, its front face is that edge pushed forward
// by "thickness".  Extruded in X this becomes a rail or the lip.
module front_band(z_lo, z_hi, thickness) {

    zs = front_edge_levels(z_lo, z_hi);

    polygon(concat(
        [for (z = zs)
            [front_depth_at(z), z]],
        [for (i = [len(zs) - 1 : -1 : 0])
            [front_depth_at(zs[i]) + thickness, zs[i]]]
    ));
}


// ============================================================
// WALL MOUNT SCREW CUTS
// ============================================================

// Shank clearance hole plus front-opening washer/head recess,
// centred in X at height z.  Cut from the cradle, not added.
// Neither one is rounded — hardware fit stays exactly as designed.
module screw_cut(z) {

    eps = 0.01;

    translate([outer_width / 2, 0, z])
        rotate([-90, 0, 0]) {

            // Shank clearance, right through the rear wall
            translate([0, 0, -eps])
                cylinder(h = back_wall + 2 * eps,
                         d = screw_shank_diameter,
                         $fn = 48);

            // Washer and head recess, open to the sensor side
            translate([0, 0, mount_barrier])
                cylinder(h = washer_recess_depth + eps,
                         d = washer_recess_diameter,
                         $fn = 64);
        }
}


module screw_cuts() {
    screw_cut(lower_screw_z);
    screw_cut(upper_screw_z);
}


// ============================================================
// FLOOR DRAIN CUTS
// ============================================================

// Straight through the bottom wall, open to the pocket above and
// to the outside below.
module drain_holes() {

    eps = 0.01;

    for (x = drain_x, y = drain_y)
        translate([x, y, -eps])
            cylinder(h = bottom_wall + 2 * eps,
                     d = drain_hole_diameter,
                     $fn = 48);
}


// ============================================================
// SIDE WINDOW CUTS
// ============================================================

// The window outline in the (depth, height) plane: front edge off
// the cradle's front profile, rear edge straight.
//
// front_depth_at() is the curve the side walls and rails already
// follow, so taking the front edge from it is what keeps the
// window parallel to the front face through the taper - no slope
// is restated - and front_edge_levels() supplies the knee as a
// breakpoint so the front edge kinks exactly where the cradle's
// does.  The rear edge is simply two points at window_rear_y.
//
// Built inset by the corner radius and offset back out, as the
// sheared version was, so the corners stay r = window_corner and
// the Z extent lands on window_z_lo .. window_z_hi.
module window_profile() {

    zs = front_edge_levels(window_z_lo + window_corner,
                           window_z_hi - window_corner);

    top = len(zs) - 1;

    offset(r = window_corner, $fn = 48)
        polygon(concat(
            // front edge, up the cradle's own front profile
            [for (z = zs)
                [front_depth_at(z) - window_front_gap - window_corner, z]],

            // rear edge, straight and parallel to the rear wall
            [[window_rear_y + window_corner, zs[top]],
             [window_rear_y + window_corner, zs[0]]]
        ));
}


// Through both side walls, same size and place on each, with both
// rims rounded like the rest of the exterior.
module window_cuts() {

    flared_cut(side_wall, edge_round) window_profile();

    mirror_x()
        flared_cut(side_wall, edge_round) window_profile();
}


// ============================================================
// DUMMY SENSOR FOR FIT CHECK
// ============================================================

module sensor_dummy() {

    // Side profile of sensor itself
    module sensor_side_profile() {
        polygon([
            [0, 0],
            [sensor_depth_bottom, 0],
            [sensor_depth_top, taper_height],
            [sensor_depth_top, sensor_height],
            [0, sensor_height]
        ]);
    }

    color("orange", 0.65)
    translate([
        side_wall + side_clearance,
        back_wall,
        bottom_wall
    ])
    rotate([90, 0, 90])
        linear_extrude(height = sensor_width)
            sensor_side_profile();
}


// ============================================================
// DESIGN CHECKS
// ============================================================

sensor_side_area =
    (sensor_depth_bottom + sensor_depth_top) / 2 * taper_height
    + sensor_depth_top * (sensor_height - taper_height);

// The window's Y depth at height z.  window_depth above the knee,
// less below it.
function window_width_at(z) =
    front_depth_at(z) - window_front_gap - window_rear_y;

// Area lost from the upright window_depth x window_height
// rectangle by the front edge following the taper below the knee.
window_taper_deficit =
    (window_z_lo < taper_top_z)
        ? (front_depth_top - front_depth_at(window_z_lo))
          * (taper_top_z - window_z_lo) / 2
        : 0;

window_area =
    window_depth * window_height
    - window_taper_deficit
    - (4 - PI) * window_corner * window_corner;

echo(str("rear wall ", back_wall, " = ", mount_barrier,
         " solid behind counterbore + ", hardware_allowance,
         " hardware allowance + ", hardware_clearance,
         " clearance to sensor"));

echo(str("hardware front face at y = ", mount_barrier + hardware_allowance,
         ", sensor rear plane at y = ", back_wall,
         ", gap = ", back_wall - mount_barrier - hardware_allowance));

echo(str("floor drains d ", drain_hole_diameter, " at x ", drain_x,
         ", y ", drain_y, ";  floor x ", side_wall, " .. ",
         outer_width - side_wall, ", y ", back_wall, " .. ",
         front_depth_bottom, ", ligament to walls ",
         drain_hole_ligament));

echo(str("sensor ", sensor_width, " x ", sensor_height,
         ", taper knee ", taper_height, " above its bottom = ",
         sensor_height - taper_height, " below its top;  cradle ",
         outer_width, " x ", outer_height,
         ", knee at z = ", taper_top_z));

echo(str("front clearance through the taper: ",
         front_depth_bottom - back_wall - sensor_depth_bottom,
         " at the knee's foot, ",
         front_depth_top - back_wall - sensor_depth_top,
         " at its top;  screws at z ", lower_screw_z, " and ",
         upper_screw_z, ", upper recess reaches z = ",
         upper_screw_z + washer_recess_diameter / 2, " of ",
         outer_height));

// Nominal: the sharp-cornered outline.  The corner offset rounds
// the sloped front flank 0.047 mm wide of nominal, so the rendered
// outline comes out 1.5 mm2 larger than this figure: 919.8 mm2.
echo(str("window ", window_depth, " x ", window_height, " less ",
         window_taper_deficit, " taper = ", window_area,
         " mm2 nominal of ", sensor_side_area, " mm2 = ",
         100 * window_area / sensor_side_area, " % of sensor side area"));

echo(str("window z ", window_z_lo, " .. ", window_z_lo + window_height,
         ", centred on sensor mid-height ", window_center_z));

// The rear edge is constant; only the front edge moves, so report
// the span at the window's bottom edge and above the knee.
echo(str("window y ", window_rear_y, " .. ",
         front_depth_at(window_z_lo) - window_front_gap,
         " = ", window_width_at(window_z_lo), " wide at z ",
         window_z_lo, ";  ", window_rear_y, " .. ",
         front_depth_top - window_front_gap, " = ",
         window_width_at(window_z_hi), " wide above the knee"));

echo(str("window front edge runs ", window_front_gap,
         " behind the side profile's front edge at every height;",
         " rear edge straight at y = ", window_rear_y,
         ", web to the rear wall ", window_rear_y - back_wall));

echo(str("screws at z ", lower_screw_z, " (", lower_screw_z,
         " from bottom) and ", upper_screw_z, " (",
         outer_height - upper_screw_z, " from top)"));


// ============================================================
// MODEL
// ============================================================

difference() {
    cradle();
    screw_cuts();
    drain_holes();
    window_cuts();
}

// sensor_dummy();
