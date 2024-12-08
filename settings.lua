-- Create control class
ControlClass = Object:extend()

-- Each control object has an ID, key to press, image for the pause menu, and the orientation of the image
function ControlClass:new(id, key, image, rotate)
    self.id = id
    self.key = key
    self.image = image
    self.image_rotate = rotate
end

-- Create control objects for each button
Left = ControlClass(1, "left", Arrow, 1.5 * math.pi)
Right = ControlClass(2, "right", Arrow, 0.5 * math.pi)
Jump = ControlClass(3, "up", Arrow, 0)
Swap = ControlClass(4, "space", Switch, 0)

-- List all control objects in a table
controls = {Left, Right, Jump, Swap}