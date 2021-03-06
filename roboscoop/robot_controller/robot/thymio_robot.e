note
	description: "Example class of the Thymio-II robot."
	author: "Rusakov Andrey"
	date: "05.09.2013"

class
	THYMIO_ROBOT

inherit
	BARRIER
	SEPARATE_STRING_MAKER

create
	make_with_attributes

feature {NONE} -- Initialization

	make_with_attributes (thymio_topics: separate THYMIO_TOPIC_PARAMETERS; range_sensors_parameters: separate RANGE_SENSORS_PARAMETERS)
			-- Create a robot with range sensors parameters.
		do
			-- Initialize sensors.
			create odometry_signaler.make_with_topic (thymio_topics.odometry)
			create range_sensors.make (thymio_topics.range_sensors, range_sensors_parameters)
			create ground_sensors.make (thymio_topics.ground_sensors)

			-- Initialize actuators.
			create diff_drive.make_with_topic (thymio_topics.velocity)
		end

feature -- Constants

	robot_base_size: REAL_64 = 0.11
			-- Robot's width.

	max_linear_speed: REAL_64 = 0.30
			-- Maximum linear speed of the robot.

feature -- Access

	set_behaviour (thymio_robot_behaviour: separate ROBOT_BEHAVIOUR)
			-- Set a behaviour for the robot to follow.
		do
			thymio_robot_behaviour.set_robot_parts (odometry_signaler, range_sensors, ground_sensors, diff_drive)
			behaviour := thymio_robot_behaviour
		end


	dispatch
			-- Start assigned behaviour.
		do
			if attached behaviour as a_behaviour then
				start_behaviour (a_behaviour)
			end
		end

	stop
			-- Stop assigned behaviour.
		do
			if attached behaviour as a_behaviour then
				stop_behaviour (a_behaviour)
			end
		end

feature {NONE} -- Robot parts

	range_sensors: separate THYMIO_RANGE_GROUP
			-- Horizontal range sensors.

	ground_sensors: separate THYMIO_GROUND_GROUP
			-- Ground sensors.

	odometry_signaler: separate ODOMETRY_SIGNALER
			-- Current state of the odometry.

	diff_drive: separate THYMIO_DIFFERENTIAL_DRIVE
			-- Differential drive.

feature {NONE} -- Implementation

	behaviour: detachable separate BEHAVIOUR

	start_behaviour (b: separate BEHAVIOUR)
			-- Launch `b'.
		do
			b.start
			io.put_string ("Behaviour started%N")
		end

	stop_behaviour (b: separate BEHAVIOUR)
			-- Terminate `b'.
		do
			b.stop
			synchronize (b)
			io.put_string ("Behaviour requested for a stop%N")
		end
end
