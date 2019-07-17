function convert_h5_to_bin(filename::String)
	Q = h5read(filename, "q")
	newname = string(filename[1:end-2], "bin")
	s = open(newname, "w+")
	# Write the dimensions of the array at the start of the file
	for j = 1:ndims(Q)
		write(s, size(Q,j))
	end
	# Write the values
	write(s, Q)
	close(s)
end