note
	description: "Controls robot during tangent bug behaviour."
	author: "Ferran Pallar�s"
	date: "06.11.15"

class
	TANGENT_BUG_CONTROLLER

inherit
	CANCELLABLE_CONTROL_LOOP

create
	make_with_attributes

feature {NONE} -- Initialization

	make_with_attributes (stop_sig: separate STOP_SIGNALER)
			-- Create controller given the attributes.
		do
			stop_signaler := stop_sig
		end

feature {TANGENT_BUG_BEHAVIOUR} -- Access

	go_to_goal (s_sig: separate STOP_SIGNALER; t_sig: separate TANGENT_BUG_SIGNALER; o_sig: separate ODOMETRY_SIGNALER;
					r_g: separate RANGE_GROUP; lift: separate LIFTABLE; d_d: separate DIFFERENTIAL_DRIVE)
			-- Move robot towards goal when no obstacle is sensed.
		require
			(not t_sig.is_minimum_distance_recorded) or t_sig.is_closer_than_minimum_distance (o_sig)
			not t_sig.is_go_to_goal_pending
			not s_sig.is_stop_requested
		do
			io.put_string ("GO TO GOAL%N")
			t_sig.clear_all_pendings
			t_sig.set_is_go_to_goal_pending (True)
		end

	follow_obstacle (s_sig: separate STOP_SIGNALER; t_sig: separate TANGENT_BUG_SIGNALER; o_sig: separate ODOMETRY_SIGNALER;
						r_g: separate RANGE_GROUP; lift: separate LIFTABLE; d_d: separate DIFFERENTIAL_DRIVE)
			-- Move robot arround sensed obstacle.
		require
			t_sig.is_obstacle_sensed (r_g)
			not t_sig.is_leave_obstacle_pending
			not s_sig.is_stop_requested
		local
			current_position: POINT_2D
			current_distance: REAL_64
		do
			io.put_string ("OBSTACLE%N")
			current_position := get_current_position (o_sig)
			current_distance := t_sig.goal.get_euclidean_distance (current_position)
			if not t_sig.is_follow_obstacle_pending then
				t_sig.set_is_follow_obstacle_pending (True)
				-- Save entry point and reset minimum distance.
				t_sig.set_obstacle_entry_point (current_position)
				t_sig.set_has_left_obstacle_entry_point (False)
				t_sig.set_minimum_distance_to_goal (current_distance)
			end
			-- Record distance to goal and update minimum.
			if current_distance < t_sig.minimum_distance_to_goal then
				t_sig.set_minimum_distance_to_goal (current_distance)
			end
		end

	leave_obstacle (s_sig: separate STOP_SIGNALER; t_sig: separate TANGENT_BUG_SIGNALER; o_sig: separate ODOMETRY_SIGNALER;
						r_g: separate RANGE_GROUP; lift: separate LIFTABLE; d_d: separate DIFFERENTIAL_DRIVE)
			-- Move robot towards a sensend safe point in space.
		require
			t_sig.is_closer_safe_point_sensed (r_g)
			t_sig.is_follow_obstacle_pending
			not t_sig.is_leave_obstacle_pending
			not s_sig.is_stop_requested
		do
			io.put_string ("LEAVE OBSTACLE%N")
			io.put_string((create {POINT_2D}.make_from_separate (r_g.get_closest_safe_point_in_front (t_sig.goal))).get_string + "%N")

			t_sig.set_is_leave_obstacle_pending (True)
			t_sig.set_is_go_to_goal_pending (False)

--			if t_sig.goal.get_euclidean_distance (get_current_position (o_sig)) < t_sig.minimum_distance_to_goal then
--				t_sig.set_is_go_to_goal_pending (False)
--			end
		end

	reached_goal (s_sig: separate STOP_SIGNALER; t_sig: separate TANGENT_BUG_SIGNALER; o_sig: separate ODOMETRY_SIGNALER;
					r_g: separate RANGE_GROUP; lift: separate LIFTABLE; d_d: separate DIFFERENTIAL_DRIVE)
			-- Proceed when the robot has reached the goal.
		require
			t_sig.is_goal_reached (o_sig)
			not t_sig.is_reached_goal_pending
			not s_sig.is_stop_requested
		do
			io.put_string ("REACHED GOAL%N")
		end

	unreachable_goal (s_sig: separate STOP_SIGNALER; t_sig: separate TANGENT_BUG_SIGNALER; o_sig: separate ODOMETRY_SIGNALER;
						r_g: separate RANGE_GROUP; lift: separate LIFTABLE; d_d: separate DIFFERENTIAL_DRIVE)
			-- Proceed when the goal is unreachable.
		require
			t_sig.is_goal_unreachable (o_sig)
			not t_sig.is_unreachable_goal_pending
			not s_sig.is_stop_requested
		do
			io.put_string ("UNREACHABLE GOAL%N")
			d_d.stop
		end

	publish_odometry (o_sig: separate ODOMETRY_SIGNALER; o_pub: separate ODOMETRY_PUBLISHER)
			-- Publish odometry
		require
			o_sig.timestamp > o_pub.timestamp
		do
			o_pub.publish_odometry (o_sig)
		end

	publish_obstacles (r_sig: separate RANGE_GROUP; o_pub: separate POINT_PUBLISHER; o_sig: separate ODOMETRY_SIGNALER)
			-- Publish odometry
		require
			r_sig.is_obstacle_in_front
		local
			idx: INTEGER_32
			point: POINT_2D
			transform: TRANSFORM_2D
		do
			from idx := r_sig.sensors.lower
			until idx > r_sig.sensors.upper
			loop
				if r_sig.sensors[idx].is_valid_range then
					create transform.make_with_offsets (r_sig.transforms[idx].x, r_sig.transforms[idx].y, r_sig.transforms[idx].get_heading)
					create point.make_from_separate (transform.project_to_parent (create {POINT_2D}.make_with_coordinates (r_sig.sensors.at (idx).range, 0)))
					create transform.make_with_offsets (o_sig.x, o_sig.y, o_sig.theta)
					o_pub.publish_point2D (transform.project_to_parent (point))
				end
				idx := idx + 1
			end
		end

	update_goal (goal_sig: separate POINT_SIGNALER; t_sig: separate TANGENT_BUG_SIGNALER)
			-- Update goal coordinates.
		require
			goal_sig.is_new_val
		do
			t_sig.set_goal_coordinates (goal_sig.data.x, goal_sig.data.y)
			goal_sig.set_new_val (False)
		end

feature {NONE} -- Implementation

	get_current_position (o_sig: separate ODOMETRY_SIGNALER): POINT_2D
			-- Return current pose.
		local
			point: POINT_2D
		do
			create point.make_with_coordinates (o_sig.x, o_sig.y)
			Result := point
		end
end
