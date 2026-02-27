import matplotlib.pyplot as plt
import numpy as np

labels = ['Software (CPU)', 'Hardware (Our FPGA)']
ntt_times = [85.0, 5.5]

x = np.arange(len(labels))
width = 0.5

fig, ax = plt.subplots(figsize=(8, 6))
rects = ax.bar(x, ntt_times, width, color=['#e74c3c', '#2ecc71'], edgecolor='black')

ax.set_ylabel('Execution Time (µs)')
ax.set_title('Performance Comparison: Kyber NTT (256 points)')
ax.set_xticks(x)
ax.set_xticklabels(labels)

def autolabel(rects):
    for rect in rects:
        height = rect.get_height()
        ax.annotate(f'{height} µs',
                    xy=(rect.get_x() + rect.get_width() / 2, height),
                    xytext=(0, 3),
                    textcoords="offset points",
                    ha='center', va='bottom', fontweight='bold')

autolabel(rects)

speedup = ntt_times[0] / ntt_times[1]
plt.text(0.5, 40, f'Speedup: {speedup:.1f}x', fontsize=12,
         bbox=dict(facecolor='white', alpha=0.5), ha='center')

plt.tight_layout()
plt.savefig('performance_benchmark.png')
plt.show()