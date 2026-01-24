@tool
extends TextureProgressBar
class_name CircularProgressBar

# Configurable properties
@export var radius: float = 80.0:
	set(value):
		radius = value
		_update_textures()

@export var background_width: float = 12.0:
	set(value):
		background_width = value
		_update_textures()

@export var progress_width: float = 18.0:
	set(value):
		progress_width = value
		_update_textures()

@export var background_color: Color = Color(0.2, 0.2, 0.2, 0.5):
	set(value):
		background_color = value
		_update_textures()

@export var progress_color: Color = Color(0.3, 0.8, 0.3, 1.0):
	set(value):
		progress_color = value
		_update_textures()

@export var antialiased: bool = true:
	set(value):
		antialiased = value
		_update_textures()

var _background_texture: ImageTexture
var _progress_texture: ImageTexture

func _ready():
	fill_mode = FILL_CLOCKWISE
	_update_textures()

func _update_textures():
	if not is_inside_tree():
		return
	
	# Calculate texture size based on radius and widths
	var max_width = max(background_width, progress_width)
	var texture_size = int((radius + max_width) * 2) + 4
	
	# Create background texture
	var bg_image = Image.create(texture_size, texture_size, false, Image.FORMAT_RGBA8)
	bg_image.fill(Color(0, 0, 0, 0))
	_draw_ring_on_image(bg_image, texture_size / 2.0, radius, background_width, 
						0, 360, background_color)
	
	_background_texture = ImageTexture.create_from_image(bg_image)
	texture_under = _background_texture
	
	# Create progress texture (full circle)
	var prog_image = Image.create(texture_size, texture_size, false, Image.FORMAT_RGBA8)
	prog_image.fill(Color(0, 0, 0, 0))
	_draw_ring_on_image(prog_image, texture_size / 2.0, radius, progress_width, 
						0, 360, progress_color)
	
	_progress_texture = ImageTexture.create_from_image(prog_image)
	texture_progress = _progress_texture
	
	# Update size to fit the texture
	custom_minimum_size = Vector2(texture_size, texture_size)
	size = Vector2(texture_size, texture_size)

func _draw_ring_on_image(image: Image, center: float, r: float, width: float, 
						 angle_from: float, angle_to: float, color: Color):
	
	var angle_range = deg_to_rad(angle_to - angle_from)
	var start_rad = deg_to_rad(angle_from)
	
	# Draw the ring by filling pixels
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var dx = x - center
			var dy = y - center
			var dist = sqrt(dx * dx + dy * dy)
			
			# Check if pixel is within the ring width
			var inner_r = r - width / 2
			var outer_r = r + width / 2
			
			if dist >= inner_r and dist <= outer_r:
				var angle = atan2(dy, dx)
				
				# Normalize angle to 0-TAU range
				if angle < 0:
					angle += TAU
				
				var check_angle = angle - start_rad
				if check_angle < 0:
					check_angle += TAU
				
				if check_angle <= angle_range:
					# Calculate distance from ring center line for antialiasing
					var dist_from_center = abs(dist - r)
					var alpha = 1.0
					
					if antialiased:
						# Smooth edges
						var edge_dist = width / 2 - dist_from_center
						if edge_dist < 1.0:
							alpha = edge_dist
					
					var final_color
					
					# Draw rounded caps
					if angle_range < TAU - 0.01:
						var start_angle_pos = Vector2(cos(start_rad), sin(start_rad)) * r
						var end_angle_rad = start_rad + angle_range
						var end_angle_pos = Vector2(cos(end_angle_rad), sin(end_angle_rad)) * r
						
						var cap_radius = width / 2
						var dist_to_start = Vector2(dx, dy).distance_to(start_angle_pos)
						var dist_to_end = Vector2(dx, dy).distance_to(end_angle_pos)
						
						if dist_to_start <= cap_radius or dist_to_end <= cap_radius:
							if antialiased:
								var cap_dist = min(dist_to_start, dist_to_end)
								if cap_dist < cap_radius:
									var cap_edge = cap_radius - cap_dist
									if cap_edge < 1.0:
										alpha = min(alpha, cap_edge)
							
							final_color = color
							final_color.a *= alpha
							image.set_pixel(x, y, final_color)
							continue
					
					final_color = color
					final_color.a *= alpha
					image.set_pixel(x, y, final_color)

# Helper function to animate progress
func animate_to_value(target_value: float, duration: float = 1.0):
	var tween = create_tween()
	tween.tween_property(self, "value", target_value, duration)
