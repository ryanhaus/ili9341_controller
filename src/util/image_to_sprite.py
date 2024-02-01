import sys
from PIL import Image

# handle command line arguments
if (len(sys.argv) != 3):
    print("Usage: python " + sys.argv[0] + " <image_file> <output_file>")
    sys.exit(1)

image_file = sys.argv[1]
output_file = sys.argv[2]



# load image
image_f = Image.open(image_file)
pixels = image_f.getdata()



# get image dimensions, verify that it is 8x8
width, height = image_f.size

if width != 128 or height != 128:
    print("Error: Image must be 128x128 px (16 x 16 tiles, 8 x 8 px each)")
    sys.exit(1)



# function for comparing two colors, lower = more similar
def color_similarity(color1, color2):
    # note: for now, this works--but perhaps conversion to Y'UV could be more useful in the future for making better comparisons
    return abs(color1[0] - color2[0]) + abs(color1[1] - color2[1]) + abs(color1[2] - color2[2])



# convert a list of pixels to a sprite instance, write sprite info to file
def image_to_sprite_write_f(pixels):
    # get all unique colors used
    colors = list(set(pixels))

    # if more than four colors are used, the four most used colors are used for the palette
    if len(colors) > 4:
        print("Warning: image contains more than four colors, determining most used colors...")

        # count how often each color is used, sort by most used
        color_count = list(map(lambda c: (c, list(pixels).count(c)), colors))
        color_count.sort(key = lambda c: c[1], reverse = True)

        # determine four most used colors
        color_count = color_count[:4]

        # create new palette
        print("New palette:")

        for i in range(min(4, len(color_count))):
            print("\t" + str(i) + ": " + str(color_count[i][0]))

        colors = list(map(lambda c: c[0], color_count))

    # ensure length of colors is 4
    while len(colors) < 4:
        colors.append((0, 0, 0))


    # for each pixel, find the closest color in the palette to it (specifically determining the color palette index of the closest color)
    pixel_indices = []

    for pixel in pixels:
        closest_index = 0

        for i in range(len(colors)):
            if color_similarity(pixel, colors[i]) < color_similarity(pixel, colors[closest_index]):
                closest_index = i

        pixel_indices.append(closest_index)



    # write output file
    colors_with_macro = list(map(lambda c: "RGB565_TO_U16(" + str(c[0]) + ", " + str(c[1]) + ", " + str(c[2]) + ")", colors))

    output_f.write("\t{\n")
    output_f.write("\t\t{ " + ", ".join(colors_with_macro) + " },\n")

    output_f.write("\t\t{ ")
    for i in range(int(len(pixel_indices) / 8)):
        current_indices = pixel_indices[i * 8 : (i + 1) * 8]

        output_f.write("INDEX8_TO_U16(" + str(current_indices[0]) + ", " + str(current_indices[1]) + ", " + str(current_indices[2]) + ", " + str(current_indices[3]) + "," + str(current_indices[4]) + ", " + str(current_indices[5]) + ", " + str(current_indices[6]) + ", " + str(current_indices[7]) + ")")

        if i < len(pixel_indices) - 1:
            output_f.write(", ")

    output_f.write("\t\t}\n")
    output_f.write("\t},\n")



output_f = open(output_file, "w")

output_f.write("// GENERATED FILE: SEE src/util/image_to_sprite.py\n");
output_f.write("#include \"../graphics_lib/sprites.h\"\n")
output_f.write("const tft_sprite SPRITES[256] = {\n")

for i in range(16):
    for j in range(16):
        pixels = list(image_f.crop((j * 8, i * 8, (j + 1) * 8, (i + 1) * 8)).getdata())
        image_to_sprite_write_f(pixels)

output_f.write("};\n")