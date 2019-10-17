function convert_h5_to_bin(filename::String, newname::String)
	Q = h5read(filename, "q")
	#newname = string(filename[1:end-2], "bin")
	s = open(newname, "w+")
	# Write the dimensions of the array at the start of the file
	for j = 1:ndims(Q)
		write(s, size(Q,j))
	end
	# Write the values
	write(s, Q)
	close(s)
end

function convert_bin_to_h5(filename::String, newname::String)
	s = open(filename)
	m = read(s, Int)
	n = read(s, Int)
	qmat = Mmap.mmap(s, Matrix{Float64}, (m,n))

	h5open(newname, "w") do file
    	write(file, "q", qmat)
    end
end