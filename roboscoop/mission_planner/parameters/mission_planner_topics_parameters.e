note
	description: "Mission Planner Topics."
	author: "Sebastian Curi"
	date: "5.11.2015"

class
	MISSION_PLANNER_TOPICS_PARAMETERS

inherit

	TOPIC_PARAMETERS

create
	make_default, make_with_attributes

feature {NONE} -- Initialize

	make_default
			-- Make default
		do
			path := "/path"
			map := "/map"
			target := "/robot_controller/goal"
			odometry := "/thymio_driver/odometry"
			path_planner_start := "/path_planner/start"
			path_planner_goal := "/path_planner/goal"
		end

	make_with_attributes (a_path, a_map, a_target, a_odometry, a_start, a_goal: STRING_8)
			-- Create `Current' and assign given attributes.
		do
			path := a_path
			map := a_map
			target := a_target
			odometry := a_odometry
			path_planner_start := a_start
			path_planner_goal := a_goal
		end

feature {ANY} -- Constants

	path: STRING_8
			-- topic where path will be read.

	map: STRING_8
			-- map to be published.

	target: STRING_8
			-- target goal for the driver.

	odometry: STRING_8
			-- odometry topic.

	path_planner_start: STRING_8
			-- start position for path_planner node.

	path_planner_goal: STRING_8
			-- goal position for path_planner node.

end
