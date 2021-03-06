note
	description: "Example application of Thymio-II in Roboscoop."
	author: "Rusakov Andrey"
	date: "10.09.2014"

class
	APP

inherit
	ROS_ENVIRONMENT
	ARGUMENTS

create
	make

feature {NONE} -- Initialization

	make
			-- Create and launch the robot.
		local
			robo_node: separate NAMED_ROBOSCOOP_NODE
			ros_spinner: separate ROS_SPINNER
			tangent_bug_behaviour: separate TANGENT_BUG_BEHAVIOUR
			led_behaviour: separate OBJECT_DISPLAY_BEHAVIOUR
			thymio: separate THYMIO_ROBOT
		do
			-- Check if correct number of command line arguments.
			if argument_count < 1 then
				io.put_string ("Usage: ./thymio_app file_path%N")
				(create {EXCEPTIONS}).die (-1)
			end

			-- Parse execution parameters
			parse_parameters

			-- Initialize this application as a ROS node.
			robo_node := (create {ROS_NAMED_NODE_STARTER}).roboscoop_node (topics.name)
			synchronize (robo_node)

			-- Listen to ROS.
			create ros_spinner.make
			start_spinning (ros_spinner)

			-- Initialize behaviour.
			create tangent_bug_behaviour.make_with_attributes (topics, tangent_bug_params)
			create led_behaviour.make_with_attributes (topics, led_code)

			-- Create a robot object.
			create thymio.make_with_attributes (thymio_topics, range_sensors_params)

			-- Set robot behaviour
			set_robot_behaviour (thymio, tangent_bug_behaviour)

			separate led_behaviour as ld do
				ld.start
			end
			-- Launch Thymio.
			separate thymio as t do
				t.dispatch
			end
		end

feature {NONE} -- Implementation

	set_robot_behaviour (robot: separate THYMIO_ROBOT; behaviour: separate ROBOT_BEHAVIOUR)
			-- Set a thymio robot's behaviour.
		do
			robot.set_behaviour(behaviour)
		end

	topics: ROBOT_CONTROLLER_TOPIC_PARAMETERS
			-- Parameters for topics for the robot controller.

	topics_parser: ROBOT_CONTROLLER_TOPICS_PARSER
			-- Parser for the parameters for topics for the robot controller.

	thymio_topics: THYMIO_TOPIC_PARAMETERS
			-- Parameters for topics for the robot controller.

	thymio_topics_parser: THYMIO_TOPIC_PARAMETERS_FILE_PARSER
			-- Parser for the parameters for topics for the robot controller.

	led_code: LED_CODE_PARAMETERS
			-- Parameters for LED code for led controller.

	led_code_parser: LED_CODE_FILE_PARSER
			-- Parser for the LED code of led controller.

	files_params: FILES_PARAMETERS
			-- Parameters for the paths of the files with parameters.

	files_params_file_parser: FILES_PARAMETERS_FILE_PARSER
			-- Parser for the parameters for the paths of the files with parameters.

	gtg_pid_params: PID_PARAMETERS
			-- PID parameters for the go to goal state.

	fw_pid_params: PID_PARAMETERS
			-- PID parameters for the follow wall state.

	lw_pid_params: PID_PARAMETERS
			-- PID parameters for the leave wall state.

	pid_params_file_parser: PID_PARAMETERS_FILE_PARSER
			-- Parser for the PID parameters.

	gtg_nlsc_params: NON_LINEAR_SPEED_CONTROLLER_PARAMETERS
			-- Non linear speed controller parameters for the go to goal state.

	fw_nlsc_params: NON_LINEAR_SPEED_CONTROLLER_PARAMETERS
			-- Non linear speed controller parameters for the follow wall state.

	lw_nlsc_params: NON_LINEAR_SPEED_CONTROLLER_PARAMETERS
			-- Non linear speed controller parameters for the leave wall state.

	nlsc_params_file_parser: NON_LINEAR_SPEED_CONTROLLER_PARAMETERS_FILE_PARSER
			-- Parser for non linear speed controller parameters.

	gtg_pose_controller_params: POSE_CONTROLLER_PARAMETERS
			-- Pose controller parameters for the go to goal state.

	fw_pose_controller_params: POSE_CONTROLLER_PARAMETERS
			-- Pose controller parameters for the follow wall state.

	lw_pose_controller_params: POSE_CONTROLLER_PARAMETERS
			-- Pose controller parameters for the leave wall state.

	pose_controller_params_file_parser: POSE_CONTROLLER_PARAMETERS_FILE_PARSER
			-- Parser for pose controller parameters.

	goal_params: GOAL_PARAMETERS
			-- Goal parameters.

	goal_params_file_parser: GOAL_PARAMETERS_FILE_PARSER
			-- Parser for the goal parameters.

	wall_following_params: WALL_FOLLOWING_PARAMETERS
			-- Parameters for the wall_following state.

	wall_following_params_file_parser: WALL_FOLLOWING_PARAMETERS_FILE_PARSER
			-- Parser for the wall_following state.

	range_sensors_params: RANGE_SENSORS_PARAMETERS
			-- Range sensor parameters.

	range_sensors_params_file_parser: RANGE_SENSORS_PARAMETERS_FILE_PARSER
			-- Parser for range sensor parameters.

	tangent_bug_params: TANGENT_BUG_PARAMETERS_BAG
			-- Parameters bag for tangent bug algorithm.

	parse_parameters
			-- Parse set of parameters.
		do
			create files_params_file_parser.make
			files_params_file_parser.parse_file (arguments.argument (1).to_string_8)
			if files_params_file_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create files_params.make_from_separate (files_params_file_parser.last_parameters)
			end

			create topics_parser.make
			topics_parser.parse_file (files_params.ros_topics_file_path)
			if topics_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create topics.make_from_separate (topics_parser.last_parameters)
			end

			create thymio_topics_parser.make
			thymio_topics_parser.parse_file (files_params.thymio_topic_path)
			if thymio_topics_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create thymio_topics.make_from_separate (thymio_topics_parser.last_parameters)
			end

			create led_code_parser.make
			led_code_parser.parse_file (files_params.led_code_file_path)
			if led_code_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create led_code.make_from_separate (led_code_parser.last_parameters)
			end

			create goal_params_file_parser.make
			goal_params_file_parser.parse_file (files_params.goal_parameters_file_path)
			if goal_params_file_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create goal_params.make_from_separate (goal_params_file_parser.last_parameters)
			end

			create pid_params_file_parser.make
			pid_params_file_parser.parse_file (files_params.go_to_goal_pid_parameters_file_path)
			if pid_params_file_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create gtg_pid_params.make_from_separate (pid_params_file_parser.last_parameters)
			end

			pid_params_file_parser.parse_file (files_params.follow_wall_pid_parameters_file_path)
			if pid_params_file_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create fw_pid_params.make_from_separate (pid_params_file_parser.last_parameters)
			end

			pid_params_file_parser.parse_file (files_params.leave_wall_pid_parameters_file_path)
			if pid_params_file_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create lw_pid_params.make_from_separate (pid_params_file_parser.last_parameters)
			end

			create nlsc_params_file_parser.make
			nlsc_params_file_parser.parse_file (files_params.go_to_goal_nlsc_parameters_file_path)
			if nlsc_params_file_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create gtg_nlsc_params.make_from_separate (nlsc_params_file_parser.last_parameters)
			end

			nlsc_params_file_parser.parse_file (files_params.follow_wall_nlsc_parameters_file_path)
			if nlsc_params_file_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create fw_nlsc_params.make_from_separate (nlsc_params_file_parser.last_parameters)
			end

			nlsc_params_file_parser.parse_file (files_params.leave_wall_nlsc_parameters_file_path)
			if nlsc_params_file_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create lw_nlsc_params.make_from_separate (nlsc_params_file_parser.last_parameters)
			end

			create pose_controller_params_file_parser.make
			pose_controller_params_file_parser.parse_file (files_params.go_to_goal_pose_controller_parameters_file_path)
			if pose_controller_params_file_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create gtg_pose_controller_params.make_from_separate (pose_controller_params_file_parser.last_parameters)
				gtg_pose_controller_params.set_pid_parameters (gtg_pid_params)
				gtg_pose_controller_params.set_nlsc_parameters (gtg_nlsc_params)
			end

			pose_controller_params_file_parser.parse_file (files_params.follow_wall_pose_controller_parameters_file_path)
			if pose_controller_params_file_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create fw_pose_controller_params.make_from_separate (pose_controller_params_file_parser.last_parameters)
				fw_pose_controller_params.set_pid_parameters (fw_pid_params)
				fw_pose_controller_params.set_nlsc_parameters (fw_nlsc_params)
			end

			pose_controller_params_file_parser.parse_file (files_params.leave_wall_pose_controller_parameters_file_path)
			if pose_controller_params_file_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create lw_pose_controller_params.make_from_separate (pose_controller_params_file_parser.last_parameters)
				lw_pose_controller_params.set_pid_parameters (lw_pid_params)
				lw_pose_controller_params.set_nlsc_parameters (lw_nlsc_params)
			end

			create wall_following_params_file_parser.make
			wall_following_params_file_parser.parse_file (files_params.wall_following_parameters_file_path)
			if wall_following_params_file_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create wall_following_params.make_from_separate (wall_following_params_file_parser.last_parameters)
			end

			create range_sensors_params_file_parser.make
			range_sensors_params_file_parser.parse_file (files_params.range_sensors_parameters_file_path)
			if range_sensors_params_file_parser.is_error_found then
				(create {EXCEPTIONS}).die (-1)
			else
				create range_sensors_params.make_from_separate (range_sensors_params_file_parser.last_parameters)
			end

			create tangent_bug_params.make_with_attributes (goal_params, wall_following_params, gtg_pose_controller_params, fw_pose_controller_params, lw_pose_controller_params)

			debug
				debug_parser
			end
		end

	debug_parser
            -- Debuger function that prints out parsed inputs.
        local
            i: INTEGER
        do
            io.put_string ("%NParameters:%N")

			io.put_string ("%NFile paths:%N")
			io.put_string ("%TGoal parameters file path: " + files_params.goal_parameters_file_path + "%N")
			io.put_string ("%TROS topics parameters file path: " + files_params.ros_topics_file_path + "%N")
			io.put_string ("%TThymio topics parameters file path: " + files_params.thymio_topic_path + "%N")
			io.put_string ("%LED code parameters file path: " + files_params.led_code_file_path + "%N")


			io.put_string ("%TRange sensors parameters file path: " + files_params.range_sensors_parameters_file_path + "%N")
			io.put_string ("%TWall following parameters file path: " + files_params.wall_following_parameters_file_path + "%N")

			io.put_string ("%TGo to goal nlsc parameters file path: " + files_params.go_to_goal_nlsc_parameters_file_path + "%N")
			io.put_string ("%TGo to goal pid parameters file path: " + files_params.go_to_goal_pid_parameters_file_path + "%N")
			io.put_string ("%TGo to goal pose parameters file path: " + files_params.go_to_goal_pose_controller_parameters_file_path + "%N")

			io.put_string ("%TFollow wall nlsc parameters file path: " + files_params.follow_wall_nlsc_parameters_file_path + "%N")
			io.put_string ("%TFollow wall pid parameters file path: " + files_params.follow_wall_pid_parameters_file_path + "%N")
			io.put_string ("%TFollow wall pose parameters file path: " + files_params.follow_wall_pose_controller_parameters_file_path + "%N")

			io.put_string ("%TLeave wall nlsc parameters file path: " + files_params.leave_wall_nlsc_parameters_file_path + "%N")
			io.put_string ("%TLeave wall pid parameters file path: " + files_params.leave_wall_pid_parameters_file_path + "%N")
			io.put_string ("%TLeave wall pose parameters file path: " + files_params.leave_wall_pose_controller_parameters_file_path + "%N")

            io.put_string ("%NTopics:%N")
            io.put_string ("%TNode name: " + topics.name + "%N")
            io.put_string ("%TCircular leds: " + topics.circular_leds_topic + "%N")
            io.put_string ("%TGoal: " + topics.goal + "%N")
            io.put_string ("%TMission odometry: " + topics.mission_odometry + "%N")
            io.put_string ("%TPath: " + topics.path + "%N")
            io.put_string ("%TPose: " + topics.pose + "%N")
            io.put_string ("%TSensed obstacles: " + topics.sensed_obstacles + "%N")
            io.put_string ("%TVisualization marker: " + topics.visualization_marker + "%N")

			io.put_string ("%NThymio Topics:%N")
            io.put_string ("%TThymio odometry: " + thymio_topics.odometry + "%N")
            io.put_string ("%TThymio velocity: " + thymio_topics.velocity + "%N")
            io.put_string ("%TThymio range sensors: " + thymio_topics.range_sensors + "%N")
            io.put_string ("%TThymio ground sensors: " + thymio_topics.ground_sensors + "%N")

            io.put_string ("%NRange sensor parameters: %N")
            io.put_string ("%TClose obstacle threshold: " + range_sensors_params.close_obstacle_threshold.out + "%N")
            io.put_string ("%TSensor count: " + range_sensors_params.sensor_count.out + "%N")

            io.put_string ("%NGo to goal parameters: %N")
            io.put_string ("%TAngular decay rate: " + gtg_pose_controller_params.nlsc_parameters.angular_decay_rate.out + "%N")
            io.put_string ("%TMaximum speed: " + gtg_pose_controller_params.nlsc_parameters.maximum_speed.out + "%N")
            io.put_string ("%TKp: " + gtg_pose_controller_params.pid_parameters.kp.out + "%N")
            io.put_string ("%TKi: " + gtg_pose_controller_params.pid_parameters.ki.out + "%N")
            io.put_string ("%TKd: " + gtg_pose_controller_params.pid_parameters.kd.out + "%N")
            io.put_string ("%TReached orientation threshold: " + gtg_pose_controller_params.reached_orientation_threshold.out + "%N")
            io.put_string ("%TReached point threshold: " + gtg_pose_controller_params.reached_point_threshold.out + "%N")
            io.put_string ("%TTurning angular speed: " + gtg_pose_controller_params.turning_angular_speed.out + "%N")

            io.put_string ("%NFollow wall parameters: %N")
            io.put_string ("%TAngular decay rate: " + fw_pose_controller_params.nlsc_parameters.angular_decay_rate.out + "%N")
            io.put_string ("%TMaximum speed: " + fw_pose_controller_params.nlsc_parameters.maximum_speed.out + "%N")
            io.put_string ("%TKp: " + fw_pose_controller_params.pid_parameters.kp.out + "%N")
            io.put_string ("%TKi: " + fw_pose_controller_params.pid_parameters.ki.out + "%N")
            io.put_string ("%TKd: " + fw_pose_controller_params.pid_parameters.kd.out + "%N")
            io.put_string ("%TReached orientation threshold: " + fw_pose_controller_params.reached_orientation_threshold.out + "%N")
            io.put_string ("%TReached point threshold: " + fw_pose_controller_params.reached_point_threshold.out + "%N")
            io.put_string ("%TTurning angular speed: " + fw_pose_controller_params.turning_angular_speed.out + "%N")

            io.put_string ("%NLeave wall parameters: %N")
            io.put_string ("%TAngular decay rate: " + lw_pose_controller_params.nlsc_parameters.angular_decay_rate.out + "%N")
            io.put_string ("%TMaximum speed: " + lw_pose_controller_params.nlsc_parameters.maximum_speed.out + "%N")
            io.put_string ("%TKp: " + lw_pose_controller_params.pid_parameters.kp.out + "%N")
            io.put_string ("%TKi: " + lw_pose_controller_params.pid_parameters.ki.out + "%N")
            io.put_string ("%TKd: " + lw_pose_controller_params.pid_parameters.kd.out + "%N")
            io.put_string ("%TReached orientation threshold: " + lw_pose_controller_params.reached_orientation_threshold.out + "%N")
            io.put_string ("%TReached point threshold: " + lw_pose_controller_params.reached_point_threshold.out + "%N")
            io.put_string ("%TTurning angular speed: " + lw_pose_controller_params.turning_angular_speed.out + "%N")

            io.put_string ("%NLED CODE: %N")
            io.put_string ("%TRed channel: " + led_code.r.out + "%N")
            io.put_string ("%TGreen channel: " + led_code.g.out + "%N")
            io.put_string ("%TBlue channel: " + led_code.b.out + "%N")
        end
end
