note
	description: "Summary description for {MISSION_PLANNER_CONTROLLER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MISSION_PLANNER_CONTROLLER

inherit

	CANCELLABLE_CONTROL_LOOP

create
	make

feature {NONE} -- Initialization

	make (s_sig: separate STOP_SIGNALER)
			-- Create `Current' and assign given attributes.
		do
			stop_signaler := s_sig
		end

feature {MISSION_PLANNER_BEHAVIOUR} -- Execute algorithm

	update_map (obstacle_sig: separate POINT_SIGNALER; mission_sig: separate MISSION_PLANNER_SIGNALER; map_sig: separate OCCUPANCY_GRID_SIGNALER; map_pub: separate OCCUPANCY_GRID_PUBLISHER; s_sig: separate STOP_SIGNALER)
			-- update map from sensor measurements.
		require
			(obstacle_sig.is_new_val or not map_pub.has_published)
			map_sig.state.info.resolution > 0
			not s_sig.is_stop_requested
		local
			idx: INTEGER
		do
			if obstacle_sig.is_new_val then
				idx := ((mission_sig.get_origin.y + obstacle_sig.data.y - map_sig.state.info.origin.position.y) / map_sig.state.info.resolution).ceiling
				idx := 1 + (idx-1) * map_sig.state.info.width.as_integer_32 + ((mission_sig.get_origin.x + obstacle_sig.data.x - map_sig.state.info.origin.position.x) / map_sig.state.info.resolution).rounded

				if map_sig.state.data.at (idx) < map_sig.occupancy_threshold then
					mission_sig.set_discovered_obstacle (True)
					map_sig.state.data.force ((2*map_sig.occupancy_threshold).as_integer_8, idx)
				end
			end

			if not map_pub.has_published then
				map_pub.publish_map (map_sig.state)
			end

			obstacle_sig.set_new_val (False)
		end

	update_target (odometry_sig: separate ODOMETRY_SIGNALER; mission_sig: separate MISSION_PLANNER_SIGNALER; target_pub: separate POINT_PUBLISHER; s_sig: separate STOP_SIGNALER)
			-- update target of robot driver.
		require
			not mission_sig.is_path_requested
			not mission_sig.path.islast
			mission_sig.path.count > 0
			not s_sig.is_stop_requested
		local
			current_point: POINT
		do
			if mission_sig.discovered_obstacle then
				target_pub.publish_point (mission_sig.get_goal - mission_sig.get_origin)
				mission_sig.path.go_i_th (mission_sig.path.count)
--				create current_point.make_with_values (odometry_sig.x + mission_sig.get_origin.x, odometry_sig.y + mission_sig.get_origin.y, odometry_sig.z + mission_sig.get_origin.z)
--				if {DOUBLE_MATH}.dabs (current_point.get_angle (mission_sig.get_current) - mission_sig.get_next.get_angle (mission_sig.get_current)) < {DOUBLE_MATH}.pi_2 then
--					mission_sig.path.forth
--					target_pub.publish_point (mission_sig.get_current - mission_sig.get_origin)
--				end
				mission_sig.set_discovered_obstacle (False)
			else
				if (create {POINT}.make_from_msg (odometry_sig.data.pose.pose.position)).euclidean_distance(mission_sig.get_current - mission_sig.get_origin) < mission_sig.goal_threshold then
					mission_sig.path.forth
					target_pub.publish_point (mission_sig.get_current - mission_sig.get_origin)
				end
			end

			if not target_pub.has_published then
				target_pub.publish_point (create {POINT}.make_with_values (0.0, 0.0, 0.0))
			end
		end

	update_path (mission_sig: separate MISSION_PLANNER_SIGNALER; path_sig: separate PATH_SIGNALER_WITH_FLAG; s_sig: separate STOP_SIGNALER)
			-- update recieved path.
		require
			path_sig.is_new_val
			path_sig.data.poses.count > 1
			not mission_sig.is_path_requested
			not s_sig.is_stop_requested
		local
			path: ARRAYED_STACK[POINT]
			current_point, next_point, following_point: POINT
			idx: INTEGER_32
		do
			path_sig.set_new_val (False)
			create path.make (0)

			io.put_string ("Recieved path size: ")
			io.put_string (path_sig.data.poses.count.out + "%N")

			current_point := create {POINT}.make_from_msg (path_sig.data.poses[1].pose.position)
			path.put (current_point)
			from
				idx := 2
			until
				idx > path_sig.count-1
			loop
				next_point := create {POINT}.make_from_msg (path_sig.data.poses[idx].pose.position)
				following_point := create {POINT}.make_from_msg (path_sig.data.poses[idx+1].pose.position)
				if {DOUBLE_MATH}.dabs (current_point.get_angle (next_point) - current_point.get_angle (following_point)) < {TRIGONOMETRY_MATH}.pi_16 and
				   current_point.euclidean_distance (next_point) > mission_sig.goal_threshold
				then
					--mission_sig.update_path (next_point)
					path.put (current_point)
					current_point := create {POINT}.make_from_separate (next_point)
				end
				idx := idx + 1
			end
			path.put (create {POINT}.make_from_msg (path_sig.data.poses[idx].pose.position))

			from
			until path.is_empty
			loop
				mission_sig.update_path (path.item)
				path.remove
			end
			mission_sig.update_path(mission_sig.get_goal)
			io.put_string ("Processed path size: " + mission_sig.path.count.out + "%N")

			if not mission_sig.way_points.islast then
				mission_sig.request_path (True)
			else
				mission_sig.request_path (False)
			end
		end

	request_path (mission_sig: separate MISSION_PLANNER_SIGNALER; obstacle_sig: separate POINT_SIGNALER; start_pub, goal_pub: separate POINT_PUBLISHER; s_sig: separate STOP_SIGNALER)
			-- request a new path to the path_planner.
		require
			not mission_sig.path.islast
			mission_sig.is_path_requested
			not obstacle_sig.is_new_val
			not s_sig.is_stop_requested
		local
			current_idx: INTEGER_32
		do
			io.put_string ("Request a path!")
			current_idx := mission_sig.way_points.index
			-- This are inverted! also reinvert in reconstruction
			goal_pub.publish_point (mission_sig.way_points.at (current_idx))
			start_pub.publish_point (mission_sig.way_points.at (current_idx+1))
			mission_sig.way_points.forth
			mission_sig.request_path (False)
		end

end
