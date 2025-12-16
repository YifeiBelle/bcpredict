# Create toy data
df <- data.frame(
  radius_mean = c(17.99, 20.57, 19.69, 11.42, 20.29),
  texture_mean = c(10.38, 17.77, 21.25, 20.38, 14.34),
  perimeter_mean = c(122.8, 132.9, 130.0, 77.58, 135.1),
  area_mean = c(1001, 1326, 1203, 386.1, 1297),
  smoothness_mean = c(0.1184, 0.08474, 0.1096, 0.1425, 0.1003),
  compactness_mean = c(0.2776, 0.07864, 0.1599, 0.2839, 0.1328),
  concavity_mean = c(0.3001, 0.0869, 0.1974, 0.2414, 0.198),
  concave.points_mean = c(0.1471, 0.07017, 0.1279, 0.1052, 0.1043),
  symmetry_mean = c(0.2419, 0.1812, 0.2069, 0.2597, 0.1809),
  fractal_dimension_mean = c(0.07871, 0.05667, 0.05999, 0.09744, 0.05883),
  radius_se = c(1.095, 0.5435, 0.7456, 0.4956, 0.7572),
  texture_se = c(0.9053, 0.7339, 0.7869, 1.156, 0.7813),
  perimeter_se = c(8.589, 3.398, 4.585, 3.445, 5.438),
  area_se = c(153.4, 74.08, 94.03, 27.23, 94.44),
  smoothness_se = c(0.006399, 0.005225, 0.00615, 0.00911, 0.01149),
  compactness_se = c(0.04904, 0.01308, 0.04006, 0.07458, 0.02461),
  concavity_se = c(0.05373, 0.0186, 0.03832, 0.05661, 0.05688),
  concave.points_se = c(0.01587, 0.0134, 0.02058, 0.01867, 0.01885),
  symmetry_se = c(0.03003, 0.01389, 0.0225, 0.05963, 0.01756),
  fractal_dimension_se = c(0.006193, 0.003532, 0.004571, 0.009208, 0.005115),
  radius_worst = c(25.38, 24.99, 23.57, 14.91, 22.54),
  texture_worst = c(17.33, 23.41, 25.53, 26.5, 16.67),
  perimeter_worst = c(184.6, 158.8, 152.5, 98.87, 152.2),
  area_worst = c(2019, 1956, 1709, 567.7, 1575),
  smoothness_worst = c(0.1622, 0.1238, 0.1444, 0.2098, 0.1374),
  compactness_worst = c(0.6656, 0.1866, 0.4245, 0.8663, 0.205),
  concavity_worst = c(0.7119, 0.2416, 0.4504, 0.6869, 0.4),
  concave.points_worst = c(0.2654, 0.186, 0.243, 0.2575, 0.1625),
  symmetry_worst = c(0.4601, 0.275, 0.3613, 0.6638, 0.2364),
  fractal_dimension_worst = c(0.1189, 0.08902, 0.08758, 0.173, 0.07678)
)
toy_data_features <- df
save(toy_data_features, file = 'data/toy_data_features.rda', compress = 'xz')
cat('Toy data created.\n')