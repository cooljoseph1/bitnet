import matplotlib.pyplot as plt
import seaborn as sns
from torchvision.datasets import MNIST
import torchvision.transforms as transforms

# Load MNIST dataset
mnist = MNIST(root='./data', train=True, download=True, transform=transforms.ToTensor())
# Assuming you're using the training set for visualization

# Extract a few samples from the dataset
image, label = mnist[0]
plt.imshow((image.squeeze()[:27, :27]>0.5))
plt.show()
