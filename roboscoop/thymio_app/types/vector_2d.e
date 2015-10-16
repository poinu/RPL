note
	description: "Summary description for {VECTOR_2D}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	VECTOR_2D

inherit
	ABSTRACT_2D
create
	make, make_with_coordinates, make_from_vector_3d_msg

feature -- Accesors

	get_unitary: VECTOR_2D
		-- get unitary vector in the direction of original vector
	local
		magnitude: REAL_64
	do
		magnitude := get_magnitude
		Result := create {VECTOR_2D}.make_with_coordinates (x/magnitude, y/magnitude)
	end

	get_magnitude: REAL_64
		-- get magnitude of vector
	do
		Result := {DOUBLE_MATH}.sqrt (x * x + y * y)
	end

	get_angle: REAL_64
		-- get vector of this angle
	local
		math : TRIGONOMETRY_MATH
	do
		create math
		Result := math.atan2(y, x)
	end

	get_perpendicular: VECTOR_2D
		-- get perpendicular to this vector
	do
		Result := create {VECTOR_2D}.make_with_coordinates (y, -x)
	end

	dot(other_line: VECTOR_2D): REAL_64
		-- dot product between lines
	do
		Result := other_line.get_x * x + other_line.get_y * y
	end

end
