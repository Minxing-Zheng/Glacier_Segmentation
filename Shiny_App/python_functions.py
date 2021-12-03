import numpy as np

def test_string_function(string):
	return(string)
	
def test_math_function(x,y):
	return(x+y)
	
def test_numpy_function(x,y):
	return(np.add(x,y))

def np_load(path):
	return(np.load(path))

def np_array(x):
	return(np.array(x))