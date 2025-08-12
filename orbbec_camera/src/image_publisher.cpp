// Copyright 2023 Intel Corporation. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include "orbbec_camera/image_publisher.h"

namespace orbbec_camera {

// --- image_rcl_publisher implementation ---
image_rcl_publisher::image_rcl_publisher(rclcpp::Node& node, const std::string& topic_name,
                                         const rmw_qos_profile_t& qos) {
  image_publisher_impl = node.create_publisher<sensor_msgs::msg::Image>(
      topic_name, rclcpp::QoS(rclcpp::QoSInitialization::from_rmw(qos), qos));
}

void image_rcl_publisher::publish(sensor_msgs::msg::Image::UniquePtr image_ptr) {
  image_publisher_impl->publish(std::move(image_ptr));
}

size_t image_rcl_publisher::get_subscription_count() const {
  return image_publisher_impl->get_subscription_count();
}

// --- image_transport_publisher implementation ---
image_transport_publisher::image_transport_publisher(rclcpp::Node& node,
                                                     const std::string& topic_name,
                                                     const rmw_qos_profile_t& qos) {
  std::string param_base = topic_name;
  std::replace(param_base.begin(), param_base.end(), '/', '.');
  param_base = "." + param_base + ".ffmpeg.";

  // Declare all FFmpeg publisher parameters
  try {
    node.declare_parameter(param_base + "encoding", "hevc_vaapi");
    node.declare_parameter(param_base + "bit_rate", 8242880);
    node.declare_parameter(param_base + "qmax", 10);
    node.declare_parameter(param_base + "gop_size", 10);

    auto all_params = node.list_parameters({}, 0).names;
    RCLCPP_INFO(node.get_logger(), "=== ALL NODE PARAMETERS ===");
    for (const auto& p : all_params) {
      if (p.find("ffmpeg") != std::string::npos || p.find("encoder") != std::string::npos) {
        RCLCPP_INFO(node.get_logger(), "  %s", p.c_str());
      }
    }
    RCLCPP_INFO(node.get_logger(), "Pre-declared FFmpeg parameters with base: %s", param_base.c_str());
  } catch (const rclcpp::exceptions::ParameterAlreadyDeclaredException &) {
    RCLCPP_INFO(node.get_logger(), "FFmpeg parameters already declared for: %s", param_base.c_str());
  }

  image_publisher_impl = std::make_shared<image_transport::Publisher>(
      image_transport::create_publisher(&node, topic_name, qos));
}
void image_transport_publisher::publish(sensor_msgs::msg::Image::UniquePtr image_ptr) {
  image_publisher_impl->publish(*image_ptr);
}

size_t image_transport_publisher::get_subscription_count() const {
  return image_publisher_impl->getNumSubscribers();
}
}  // namespace orbbec_camera