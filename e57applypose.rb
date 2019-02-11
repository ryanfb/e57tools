#!/usr/bin/env ruby

require 'matrix'
require 'csv'

# from http://www.libe57.org/best.html under E57 Reader Best Practices > Converting Quaternion to Matrix
def quaternion_to_matrix(w, x, y, z)
  mat = Matrix[
    [
      1.0 - 2.0*y*y - 2.0*z*z,
      2.0*x*y - 2.0*z*w,
      2.0*x*z + 2.0*y*w
    ],
    [
      2.0*x*y + 2.0*z*w,
      1.0 - 2.0*x*x - 2.0*z*z,
      2.0*y*z - 2.0*x*w
    ],
    [
      2.0*x*z - 2.0*y*w,
      2.0*y*z + 2.0*x*w,
      1.0 - 2.0*x*x - 2.0*y*y
    ]
  ]

  return mat
end

unless ARGV.length == 3
  $stderr.puts "Usage: ./e57applypose.rb input.inf input.csv output.csv"
  exit 1
end

pose = {}
File.readlines(ARGV[0]).each do |line|
  if /^pose\.(?<type>translation|rotation)\.(?<attribute>[wxyz]) = (?<value>.+)$/ =~ line
    pose[type] ||= {}
    pose[type][attribute] = value.to_f
  end
end

$stderr.puts pose

rotation_matrix = quaternion_to_matrix(pose['rotation']['w'],pose['rotation']['x'],pose['rotation']['y'],pose['rotation']['z'])
$stderr.puts rotation_matrix

translation_matrix = Matrix[[pose['translation']['x']],[pose['translation']['y']],[pose['translation']['z']]]
$stderr.puts translation_matrix

$stderr.puts "Applying pose transformation..."
# cartesianX,cartesianY,cartesianZ,intensity,colorRed,colorGreen,colorBlue,rowIndex,columnIndex,cartesianInvalidState
headers_written = false
CSV.open(ARGV[2], "w") do |csv_output|
  CSV.foreach(ARGV[1], :headers => true) do |row|
    point = Matrix[[row['cartesianX'].to_f],[row['cartesianY'].to_f],[row['cartesianZ'].to_f]]
    rotated_point = (rotation_matrix * point) + translation_matrix
    row_hash = row.to_h
    unless headers_written
      csv_output << row_hash.keys.map{|i| i == "intensity" ? "Grey" : i}
      headers_written = true
    end
    rotated_point_array = rotated_point.transpose.to_a.flatten
    row_hash['cartesianX'] = rotated_point_array[0]
    row_hash['cartesianY'] = rotated_point_array[1]
    row_hash['cartesianZ'] = rotated_point_array[2]
    if row_hash.has_key?('intensity')
      intensity = row_hash['intensity'].to_f
      # row_hash['colorRed'] = (row_hash['colorRed'].to_i * intensity).to_i if row_hash['colorRed']
      # row_hash['colorGreen'] = (row_hash['colorGreen'].to_i * intensity).to_i if row_hash['colorGreen']
      # row_hash['colorBlue'] = (row_hash['colorBlue'].to_i * intensity).to_i if row_hash['colorBlue']
    end
    if row_hash.has_key?('cartesianInvalidState') && (row_hash['cartesianInvalidState'].to_i != 0)
    else
      csv_output << row_hash.values
    end
    # $stderr.puts rotated_point
  end
end
$stderr.puts "Done."
