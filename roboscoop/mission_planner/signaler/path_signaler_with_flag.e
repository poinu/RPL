note
	description: "Current state of the path and a recieve flag."
	author: "Rusakov Andrey"
	date: "20.11.2013"

class
	PATH_SIGNALER_WITH_FLAG

inherit
	PATH_LISTENER

create
	make_with_topic

feature {NONE} -- Initialization

	make_with_topic (topic_name: separate STRING)
			-- Create Current.
		do
			create data.make_empty
			create subscriber.make
			subscribe_path (subscriber, Current, topic_name)
			is_new_val := False
		end

feature -- Access

	is_new_val: BOOLEAN
			-- Is a new path recieved.

	data: PATH_MSG
		-- Current state.

	count: INTEGER
			-- Number of poses in the path.
		do
			Result := data.poses.count
		end

	pose_i_th (index: INTEGER): separate POSE_STAMPED_MSG
			-- I'th element of poses.
		require
			index >= data.poses.lower and index <= data.poses.upper
		do
			Result := data.poses [index]
		end

	update_path (msg: separate PATH_MSG)
			-- Update current state with the values from `msg'.
		do
			create data.make_from_separate (msg)
			is_new_val := True
		end

	set_new_val (a_val: BOOLEAN)
			-- Set is_new_val to  `a_val'.
		do
			is_new_val := a_val
		end

feature {NONE} -- Implementation

	subscriber: separate ROS_SUBSCRIBER [PATH_MSG]
			-- Subscriber object.

	subscribe_path (a_sub: separate ROS_SUBSCRIBER [PATH_MSG];
							a_listener: separate PATH_LISTENER; a_topic: separate STRING)
			-- Subscriber for odometry update.
		do
			a_sub.subscribe (a_topic, agent a_listener.update_path)
		end
end
