Q = 16
SCALE = 1 << Q

def float_to_fixed(val):
    return int(val * SCALE)

def fixed_to_float(val):
    return val / SCALE

def find_min_max_fpga_fixed(coeffs_fixed, start_fixed, end_fixed, num_steps):
    step_size_fixed = (end_fixed - start_fixed) // num_steps
    
    current_x = start_fixed
    val = coeffs_fixed[0]
    for c in coeffs_fixed[1:]:
        val = (val * current_x) >> Q
        val += c
        
    min_val = val
    max_val = val
    min_x = current_x
    max_x = current_x

    for i in range(1, num_steps + 1):
        current_x = start_fixed + i * step_size_fixed
        
        current_val = coeffs_fixed[0]
        for j in range(1, len(coeffs_fixed)):
            current_val = (current_val * current_x) >> Q
            current_val += coeffs_fixed[j]

        if current_val < min_val:
            min_val = current_val
            min_x = current_x
            
        if current_val > max_val:
            max_val = current_val
            max_x = current_x

    return (min_x, min_val), (max_x, max_val)

# ---------------------
coefficients = [2.0, -3.0, -12.0, 5.0] 
interval_start = -3.0
interval_end = 4.0
steps = 1000

coeffs_fixed = [float_to_fixed(c) for c in coefficients]
start_fixed = float_to_fixed(interval_start)
end_fixed = float_to_fixed(interval_end)

min_fixed, max_fixed = find_min_max_fpga_fixed(coeffs_fixed, start_fixed, end_fixed, steps)

print(f"Minimum: x = {fixed_to_float(min_fixed[0]):.4f}, y = {fixed_to_float(min_fixed[1]):.4f}")
print(f"Maksimum: x = {fixed_to_float(max_fixed[0]):.4f}, y = {fixed_to_float(max_fixed[1]):.4f}")