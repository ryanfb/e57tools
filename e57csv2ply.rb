#!/usr/bin/env ruby

require 'csv'
require 'tempfile'

unless ARGV.length >= 2
  $stderr.puts "Usage: ./e57csv2ply.rb input1.csv [input2.csv input3.csv ...] output.ply"
  exit 1
end

output_filename = ARGV.pop
tempfile = Tempfile.new()
puts tempfile.path
last_vertex = nil
begin
  vertices = 0
  $stderr.puts "Parsing #{ARGV.length} input files..."
  # cartesianX,cartesianY,cartesianZ,intensity,colorRed,colorGreen,colorBlue,rowIndex,columnIndex,cartesianInvalidState
  ARGV.each do |input_filename|
    $stderr.puts "Parsing #{input_filename}"
    CSV.foreach(input_filename, :headers => true) do |row|
      output = {}
      row_hash = row.to_h
      output['x'] = row_hash['cartesianX']
      output['y'] = row_hash['cartesianY']
      output['z'] = row_hash['cartesianZ']
      output['alpha'] = row_hash['intensity'].to_f if row_hash['intensity']
      output['alpha'] = row_hash['Grey'].to_f if row_hash['Grey']
      output['diffuse_red'] = row_hash['colorRed'].to_i if row_hash['colorRed']
      output['diffuse_green'] = row_hash['colorGreen'].to_i if row_hash['colorGreen']
      output['diffuse_blue'] = row_hash['colorBlue'].to_i if row_hash['colorBlue']
      output_elements = []
      ['x','y','z','diffuse_red','diffuse_green','diffuse_blue','alpha'].each do |element|
        output_elements << output[element] if output.has_key?(element)
      end
      tempfile.puts output_elements.join(' ')
      vertices += 1
      last_vertex = output
    end
  end
  tempfile.close

  $stderr.puts "Writing output to #{output_filename} (#{vertices} vertices)..."
  File.open(output_filename, 'w') do |output|
    output.puts 'ply'
    output.puts 'format ascii 1.0'
    output.puts "element vertex #{vertices}"
    ['x','y','z'].each do |i|
      output.puts "property float #{i}"
    end
    ['red','green','blue'].each do |color|
      output.puts "property uchar diffuse_#{color}" if last_vertex.has_key?("diffuse_#{color}")
    end
    output.puts "property float alpha" if last_vertex.has_key?('alpha')
    output.puts 'end_header'
    File.foreach(tempfile.path) do |line|
      output.puts line
    end
  end
ensure
  tempfile.unlink
end
