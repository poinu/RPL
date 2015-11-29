note
	description: "Class utility to transform a node list into a PATH MSG."
	author: "Sebastian Curi"
	date: "28.11.2015"

class
	PATH_MSG_FROM_NODE_LIST

feature -- Access

	get_path_msg_from_nodes (path: separate LIST [SPATIAL_GRAPH_NODE]; frame: separate STRING_8): separate PATH_MSG
			-- Get path_msg from a list of nodes.
		local
			msg: PATH_MSG
			header: HEADER_MSG
			pose: POSE_MSG
			a_poses: ARRAY [POSE_STAMPED_MSG]
			idx: INTEGER_32
		do
			header := create {HEADER_MSG}.make_now (create {STRING_8}.make_from_separate (frame))
			create a_poses.make_filled (create {POSE_STAMPED_MSG}.make_empty, 1, path.count)
			idx := 1
			from
			until
				path.is_empty
			loop
				pose := create {POSE_MSG}.make_with_values (create {POINT_MSG}.make_from_separate (path.item.position), create {QUATERNION_MSG}.make_empty)
				a_poses.put (create {POSE_STAMPED_MSG}.make_with_values (header, pose), idx)
				path.remove
				idx := idx + 1
			end
			create msg.make_with_values (header, a_poses)
			Result := msg
		end
end
