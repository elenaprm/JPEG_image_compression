% compE565 Homework 2
% Oct. 26, 2021
% Name: Elena Pérez-Ródenas Martínez
% ID: 827-22-2533
% email: eperezrodenasm3836@sdsu.edu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 1: Encoder
% Location of input image: C:\Users\Elena Pérez-Ródenas\Desktop\SDSU\
% MULTIMEDIA COMMUNICATIONSYSTEMS\Flooded_house.jpg (user should change this 
% according to the location of the file)
% M-file name: zigzag2d.m
% output image: Figure 1: Y, Cb, Cr after 2D-DCT
% Figure 2: First DCT transformed image block
% Figure 3: Second DCT transformed image block
% Figure 4: First block of the 6th row after quantization
% Figure 5: Second block of the 6th row after quantization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear all
close all
I=imread("C:\Users\Elena Pérez-Ródenas\Desktop\SDSU\MULTIMEDIA COMMUNICATION SYSTEMS\Flooded_house.jpg","jpg");
ycbcr=rgb2ycbcr(I);
Y=ycbcr(:,:,1);
Cb=ycbcr(:,:,2);
Cr=ycbcr(:,:,3);
Cb420=Cb(1:2:end, 1:2:end);
Cr420=Cr(1:2:end, 1:2:end);
%a)8x8 block DCT transform coefficients
dct_function = @(block_struct) dct2(block_struct.data);
Y_dct = blockproc(Y,[8,8],dct_function);
Cb_dct = blockproc(Cb420,[8,8],dct_function,'PadPartialBlocks',true);
Cr_dct = blockproc(Cr420,[8,8],dct_function,'PadPartialBlocks',true);
figure(1)
subplot(2,2,1), imshow(Y_dct), title("Y after 2D-DCT")
subplot(2,2,2), imshow(Cb_dct), title("Cb420 after 2D-DCT")
subplot(2,2,3), imshow(Cr_dct), title("Cr420 after 2D-DCT")

fprintf("Coefficient matrix of the first DCT transformed image block\n")
block1R6 = Y_dct(41:48,1:8)
figure(2)
imshow(block1R6), title("First DCT transformed image block")
fprintf("Coefficient matrix of the second DCT transformed image block\ns")
block2R6 = Y_dct(41:48,9:16)
figure(3)
imshow(block2R6), title("Second DCT transformed image block")

%b)quantization of the DCT image
LumQMatrix = [16 11 10 16 24 40 51 61; 
              12 12 14 19 26 58 60 55; 
              14 13 16 24 40 57 69 56; 
              14 17 22 29 51 87 80 62; 
              18 22 37 56 68 109 103 77;
              24 35 55 64 81 104 113 92;
              49 64 78 87 103 121 120 101; 
              72 92 95 98 112 100 103 99];
ChromQMatrix = [17 18 24 47 99 99 99 99; 
                18 21 26 66 99 99 99 99;
                24 26 56 99 99 99 99 99;
                47 66 99 99 99 99 99 99;
                99 99 99 99 99 99 99 99;
                99 99 99 99 99 99 99 99;
                99 99 99 99 99 99 99 99;
                99 99 99 99 99 99 99 99];
Quant_Luma = @(block_struct) round(block_struct.data./LumQMatrix);
Quant_Chroma = @(block_struct) round(block_struct.data./ChromQMatrix);
Y_Q = blockproc(Y_dct, [8 8], Quant_Luma);
Cb_Q = blockproc(Cb_dct, [8 8], Quant_Chroma);
Cr_Q = blockproc(Cr_dct, [8 8], Quant_Chroma);

Block1_Q = Y_Q(41:48,1:8);
figure(4)
imshow(Block1_Q), title("First block of the 6th row after quantization")
Block2_Q = Y_Q(41:48,9:16);
figure(5)
imshow(Block2_Q), title("Second block of the 6th row after quantization")

fprintf("The DC coefficient for the first 8x8 block of Y is %d\n", Block1_Q(1:1))
fprintf("The DC coefficient for the second 8x8 block of Y is %d\n", Block2_Q(1:1))
Block1_zz = zigzag2d(Block1_Q);
Block2_zz = zigzag2d(Block2_Q);
AC_block1 = Block1_zz(2:end)
AC_block2 = Block2_zz(2:end)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Problem 2: Decoder
% output image: Figure 6: Y, Cb, Cr after inversed quantization
% Figure 7: Reconstructed RGB image
% Figure 8: Error Image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%c)inversed Quantized images
InvQ_Luma = @(block_struct) round(block_struct.data*LumQMatrix);
InvQ_Chroma = @(block_struct) round(block_struct.data*ChromQMatrix);
Y_invQ = blockproc(Y_Q, [8 8], InvQ_Luma);
Cb_invQ = blockproc(Cb_Q, [8 8], InvQ_Chroma);
Cr_invQ = blockproc(Cr_Q, [8 8], InvQ_Chroma);
figure(6)
subplot(2,2,1), imshow(Y_invQ), title("Y after inversed quantization")
subplot(2,2,2), imshow(Cb_invQ), title("Cb after inversed quantization")
subplot(2,2,3), imshow(Cr_invQ), title("Cr after inversed quantization")

%d)reconstruct computing inverse DCT coefficients
IDCT_function = @(block_struct) idct2(block_struct.data);
Y_IDCT = blockproc(Y_invQ, [8 8], IDCT_function);
Cb_IDCT = blockproc(Cb_invQ, [8 8], IDCT_function);
Cr_IDCT = blockproc(Cr_invQ, [8 8], IDCT_function);
Cb_new = Cb;
Cb_new(2:2:end, 2:2:end) = Cb_new(1:2:end,1:2:end);
Cr_new = Cr;
Cr_new(2:2:end, 2:2:end) = Cr_new(1:2:end,1:2:end);
NEW = cat(3,Y,Cb_new,Cr_new);
RGB_NEW = ycbcr2rgb(NEW);
figure(7)
imshow(RGB_NEW), title("Reconstructed RGB image")

%error image
Image_Error = abs(double(Y) - Y_IDCT);
figure(8)
imshow(Image_Error,[0 max(Image_Error(:))]), title("Error Image")

%psnr
MSE = mean(Image_Error(:).^2)
PSNR = 10*log10(255.^2/MSE)