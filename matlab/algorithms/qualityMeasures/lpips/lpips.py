from models import dist_model as dm
from util import util

def compute(image_file1, image_file2, gpu_flag):

	## Initializing the model
	model = dm.DistModel()
	model.initialize(model='net-lin', net='squeeze', use_gpu=gpu_flag)

	# Load images
	img0 = util.im2tensor(util.load_image(image_file1)) # RGB image from [-1,1]
	img1 = util.im2tensor(util.load_image(image_file2))

	# Compute distance
	dist01 = model.forward(img0, img1)
	
	return float(dist01[0])
