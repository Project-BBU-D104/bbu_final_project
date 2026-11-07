from app.seeders.create_test_data import compute_stock_qty


def test_sums_base_and_signed_movements():
    assert compute_stock_qty(10, [5, -3]) == 12


def test_no_movements_returns_base():
    assert compute_stock_qty(7, []) == 7


def test_clamps_at_zero():
    assert compute_stock_qty(2, [-5]) == 0