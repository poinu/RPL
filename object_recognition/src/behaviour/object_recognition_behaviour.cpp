#include "object_recognition_behaviour.h"

ObjectRecognitionBehaviour::ObjectRecognitionBehaviour(std::vector<FilterPtr> filters, SegmentationPtr segmentator,
                                                       DescriptorPtr spin_image, CorrespondencePtr correspondence)
{
  _recognition_pipeline = ObjectRecognitionController(filters, segmentator, spin_image, correspondence);
  is_requested = false;
}

void ObjectRecognitionBehaviour::set_filters(std::vector<FilterPtr> filters){
  _recognition_pipeline.set_filters(filters);
}

void ObjectRecognitionBehaviour::set_segmentator(SegmentationPtr segmentator){
  _recognition_pipeline.set_segmentator(segmentator);
}

void ObjectRecognitionBehaviour::set_descriptor(DescriptorPtr spin_image){
  _recognition_pipeline.set_descriptor(spin_image);
}

void ObjectRecognitionBehaviour::set_correspondence(CorrespondencePtr correspondence){
  _recognition_pipeline.set_correspondence(correspondence);
}

void ObjectRecognitionBehaviour::image_callback(const PointCloud::ConstPtr& msg)
{
  if (is_requested){
    ROS_INFO("I heard a new msg!");
    _listener.msg_callback(msg);

    _recognition_pipeline.pre_process_image(_listener.get_cloud());
    std::vector<PointCloud> clusters = _recognition_pipeline.get_clusters();

    for (std::vector<PointCloud>::iterator it = clusters.begin(); it != clusters.end(); ++it){
      Eigen::Vector4f min, max, mean, difference;
      pcl::getMinMax3D(*it, min, max);
      mean = 0.5 * (min + max);
      difference = max - min;

      _recognition_pipeline.recognize_image(*it, 1);
      publish(mean, difference, 1);
    }
    ROS_INFO("Finished processing point cloud");
    is_requested = false;
  }

  /*
  if ((_segmentator->get_cluster_indices()).size() != _markers.size())
  {
    reset_publisher();
    ROS_WARN("Errasing markers");
  }
  _markers.clear();
  for (size_t i = 0; i < (_segmentator->get_cluster_indices()).size(); ++i)
  {
    recognize_image(_segmentator->get_cluster_cloud(i), i);
  }
    */
}

void ObjectRecognitionBehaviour::set_marker_publisher(ros::Publisher marker_publisher)
{
  _marker_publisher = marker_publisher;
}

void ObjectRecognitionBehaviour::set_models(std::vector<Category> categories)
{
  _recognition_pipeline.set_models(categories);
  ROS_INFO("Categories set!");
}

void ObjectRecognitionBehaviour::publish(Eigen::Vector4f position, Eigen::Vector4f scale, int cluster_number)
{
  std::vector<Category> categories = _recognition_pipeline.get_categories();
  for (std::vector<Category>::iterator it = categories.begin(); it != categories.end(); ++it)
  {
    if (it->is_detected())
    {
      MarkerMessage marker;
      marker.set_position(static_cast<double>(position[0]), static_cast<double>(position[1]),
                          static_cast<double>(position[2]));
      marker.set_scale(static_cast<double>(scale[0]), static_cast<double>(scale[1]), static_cast<double>(scale[2]));
      marker.set_id(cluster_number);
      marker.set_color(it->get_color());
      marker.set_frame_id(_frame);
      _markers.push_back(marker);
      _marker_publisher.publish(marker.get_marker());
    }
  }
}

void ObjectRecognitionBehaviour::reset_publisher(void)
{
  MarkerMessage marker;
  marker.set_frame_id(_frame);
  marker.set_action(DELETE_ALL);
  _marker_publisher.publish(marker.get_marker());
}

void ObjectRecognitionBehaviour::set_image_frame(const std::string frame)
{
  _frame = frame;
}

void ObjectRecognitionBehaviour::request_callback(const std_msgs::EmptyPtr & msg){
  is_requested = true;
}
