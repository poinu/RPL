note
	description: "Main parser for this application."
	author: "Sebastian Curi"
	date: "06.11.2015"

class
	MISSION_PLANNER_PARAMETER_PARSER

inherit

	PARAMETERS_FILE_PARSER


feature {ANY} -- Acces.

	parse_file (file_path: STRING): MISSION_PLANNER_PARAMETERS
			-- Parse file with path `file_path'.
		local
			point_array: ARRAYED_LIST[POINT]
			x, y, z: REAL_64
			way_point_threshold: REAL_64
			file: PLAIN_TEXT_FILE
			key: STRING
		do
			create point_array.make (0)
			create file.make_open_read (file_path)
			from
				file.start
			until
				file.off
			loop
				file.read_word
				key := file.last_string

				if key.is_equal ("point:") then
					file.read_double
					x := file.last_double
					file.read_double
					y := file.last_double
					point_array.force (create {POINT}.make_with_values (x, y, 0))
				elseif key.is_equal ("way_point_threshold:") then
					file.read_double
					way_point_threshold := file.last_double
				elseif not key.is_empty then
					io.putstring ("Parser error while parsing file '" + file_path + "': Key '" + key + "' not recognized%N")
				end
			end
			file.close
			point_array.start
			Result := create {MISSION_PLANNER_PARAMETERS}.make_with_attributes (point_array, way_point_threshold)
		end

end
