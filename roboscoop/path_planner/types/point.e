note
	description: "A 3D point implementation."
	author: "Sebastian Curi"
	date: "05.11.2015"

class
	POINT

create
	make_default, make_with_values, make_from_separate, make_from_msg

feature {NONE} -- Initialization

	make_default
			-- Make `Current' with default values.
		do
			x := 0
			y := 0
			z := 0
		end

	make_with_values (a_x, a_y, a_z: REAL_64)
			-- Make `Current' with given values.
		do
			x := a_x
			y := a_y
			z := a_z
		end

	make_from_separate (other: separate like Current)
			-- Make `Current' with given values.
		do
			x := other.x
			y := other.y
			z := other.z
		end

	make_from_msg (msg: separate POINT_MSG)
			-- Make `Current' with given values.
		do
			x := msg.x
			y := msg.y
			z := msg.z
		end


feature {ANY} -- Access

	x: REAL_64
			-- x coordinate.

	y: REAL_64
			-- y coordinate.

	z: REAL_64
			-- z coordinate.

	get_msg: POINT_MSG
			-- Get point_msg associated to this point.
		do
			Result := create {POINT_MSG}.make_with_values (x, y, z)
		end

	euclidean_distance (other: separate POINT): REAL_64
			-- Return eculidean distance between current point and other.
		local
			dx, dy, dz: REAL_64
		do
			dx := x - other.x
			dy := y - other.y
			dz := z - other.z
			Result := {DOUBLE_MATH}.sqrt (dx * dx + dy * dy + dz * dz)
		end

	manhattan_distance (other: separate POINT): REAL_64
			-- Return manhattan distance between current point and other.
		local
			dx, dy, dz: REAL_64
		do
			dx := {DOUBLE_MATH}.dabs (x - other.x)
			dy := {DOUBLE_MATH}.dabs (y - other.y)
			dz := {DOUBLE_MATH}.dabs (z - other.z)
			Result := dx + dy + dz
		end

	get_angle (other: separate POINT): REAL_64
			-- Return angle of the vector (in 2D only) connecting two points.
		require
			other.z = z
		local
			tmath:TRIGONOMETRY_MATH
			dx, dy: REAL_64
		do
			dx := x - other.x
			dy := y - other.y
			create tmath
			Result := tmath.atan2 (dy, dx)
		end

	get_string: STRING_8
			-- Return string representation of point.
		do
			Result := "x: " + x.out + " y: " + y.out + " z: " + z.out
		end

end
