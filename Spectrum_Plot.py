import os
import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import find_peaks
root = os.getcwd()

period = 375
ITO_wg = 163
gratingthickness = 128
ITO_under = ITO_wg - gratingthickness
dutycycle = 0.68
ridgewidth = period * dutycycle
gratingindex = 2.210

loss = 0.01
glassindex = 1.45
nharm = 20
TEamp = 1
TMamp = 0
z_field = 450

eps_r = gratingindex**2 - loss**2
eps_i = 2 * gratingindex * loss

gratingindex1 = gratingindex

lambdain = 500
lambdafin = 1000
npoints = 900;
deltalambda = (lambdafin - lambdain) / npoints

simulate = True
if simulate:
        args = (f'period = {period}; gratingthickness = {gratingthickness}; dutycycle = {dutycycle};'
                f'ridgewidth = {ridgewidth}; nharm = {nharm}; lambdain = {lambdain}; lambdafin = {lambdafin}; loss = {loss};'
                f'z_field= {z_field}; ITO_under = {ITO_under}; deltalambda = {deltalambda}; gratingindex = {gratingindex};'
                f'glassindex = {glassindex}; TEamp = {TEamp}; TMamp = {TMamp}; ITO_wg = {ITO_wg}; gratingindex1 = {gratingindex1};'
                f'eps_r = {eps_r}; eps_i = {eps_i};')

        lua_script = 'Code/Projects/GMR/Standard_GMR.lua'
        os.system(f'S4 -a "{args}" {lua_script}')

# datafilename = '/Volumes/Sam/Sputterer_PC/data.csv'
datafilename = '/Users/samblair/Desktop/data.csv'
datafilepath = os.path.join(
    root,
    datafilename)
lam, spectrum, Eyr, Eyi = np.genfromtxt(
    fname=datafilepath,
    delimiter=",",
    skip_header=1,
    unpack=True)

epsfilename = '/Users/samblair/Desktop/eps.csv'
epsfilepath = os.path.join(
    root,
    epsfilename)
x, eps = np.genfromtxt(
    fname=epsfilepath,
    delimiter=",",
    skip_header=0,
    unpack=True)

### Calculations ###
Eyphi = np.arctan2(Eyi,Eyr)
phase1a = np.unwrap(Eyphi, period=np.pi)
phase1 = phase1a/np.pi
# phase1 = (phase1b * (-1))
# phase1 = phase1b + 2
spectrum1 = spectrum*100

# ### Phase Values ###
# value = 655.55555
# def find_nearest(data_array, value):
#     data_array = np.asarray(data_array)
#     idx = np.abs(data_array - value).argmin()
#     return idx 
# a = find_nearest(lam, value)
# print('a=', a, 'lam[a]=', lam[a])
# phase_array = np.asarray(phase1)
# phase_pos = phase_array[a]
# print('phase position=', phase_pos)
# spectrum_array = np.array((spectrum1))
# trans = ((1 - spectrum_array)*-1)

### FWHM ###
def FWHM(lam,spectrum1):
    deltax = lam[1] - lam[0]
    half_max = max(spectrum1) / 2
    l = np.where(spectrum1 > half_max, 1, 0)
    
    return np.sum(l) * deltax

k = FWHM(lam, spectrum1)
FWHM1 = np.around(k, 5)
# print('FWHM=', FWHM1)

 ### Plot ###
fig, ax = plt.subplots()
ax.plot(lam, spectrum1, 'k', lw=2, label='Reflection')
ax2 = ax.twinx()
ax2.plot(lam, phase1, 'c', lw=2, label='Phase')
ax.set_xlabel('Wavelength [nm]', fontsize=21, fontweight='bold')
ax.set_ylabel('Reflection', fontsize=22, fontweight='bold', color='k')
ax2.set_ylabel('Phase/π', fontsize=22, fontweight='bold', color = 'c')
ax.tick_params(axis='both', labelsize=22)
# plt.axis([None, None, -1, 1])
ax2.tick_params(axis='both', labelsize=22)
#ax.legend(frameon=True, loc='lower right', prop={'size': 14})
#ax2.legend(frameon=True, loc='upper left', prop={'size': 14})
# plt.text(0.94, 0.98,''+str(FWHM1)+'', ha='center', va='center', fontsize=10, fontweight='bold', color='c', transform=ax.transAxes)
# plt.title('ITO GMR Single Mode \n [P='+str(period)+' FF='+str(dutycycle)+'], εi = '+str(loss_ITO)+', T = '+str(gratingthickness)+'', fontsize=16, fontweight='bold')
#plt.axvline(x=653, color='r', lw=1)
# plt.ylim([-1, 1])
# plt.xlim([500, 800])

#### PEAKS ####
idx_y, _ = find_peaks(spectrum1, height=70)
peaks_y = spectrum1[idx_y]
peaks_x = lam[idx_y]
# print('Refl Peak Index=', idx_y, 'Refl Peak Value=', peaks_y)
print('Peak Lambda=', peaks_x, 'Refl Max=', peaks_y)

# fig, ax = plt.subplots(1, 1, figsize=(12, 6))
# ax.plot(x, eps, 'b', lw=2, label='Epsilon')
# ax.set_xlabel('Location (nm)', fontsize=16)
# ax.set_ylabel('Epsilon', color='b', fontsize=16)
# ax.tick_params(axis='both', labelsize=14)
# plt.title('', fontsize=22, fontweight='bold')

plt.tight_layout()
plt.show()

