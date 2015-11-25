/*
 * pass_through_filter.cpp
 *
 *  Created on: Nov 17, 2015
 *      Author: Sebastian Curi
 */

#include "pass_through_filter.h"

PassThroughFilter::PassThroughFilter()
{
  pass_through_filter_parameters params = pass_through_filter_parameters();
  _filter.setFilterFieldName(params.field);
  _filter.setFilterLimits(params.min, params.max);
  _name = "Pass_Through_Filter";
}

PassThroughFilter::PassThroughFilter(struct pass_through_filter_parameters params)
{
  _filter.setFilterFieldName(params.field);
  _filter.setFilterLimits(params.min, params.max);
  _name = "Pass_Through_Filter";
}

PassThroughFilter::PassThroughFilter(double z_min, double z_max, std::string field)
{
  _filter.setFilterFieldName(field);
  _filter.setFilterLimits(z_min, z_max);
  _name = "Pass_Through_Filter";
}

void PassThroughFilter::set_filter_limits(double z_min, double z_max)
{
  _filter.setFilterLimits(z_min, z_max);
}
void PassThroughFilter::set_filter_field(std::string field)
{
  _filter.setFilterFieldName(field);
}

void PassThroughFilter::filter(const PointCloud::Ptr & cloud)
{
  _filter.setInputCloud(cloud);
  _filter.filter(_cloud_filtered);
}
