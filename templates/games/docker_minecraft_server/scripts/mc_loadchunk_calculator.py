"""Script to help with getting Minecraft chunk coordinates from x,y,z coordinates.

This is useful with certain mods, like Tom's Simple Storage, which has a globally
accessible storage system, but only while the chunk with a transmitter is active.

After grabbing the coordinates for a point on the map near the chunk(s) you want
to keep loaded, run this script and pass them with -x [X coord] -y [Y coord] -z [Z coord]
and the script will return the chunk address for those coordinates.

Copy and paste the command output into your game to keep that chunk loaded.
"""

from pathlib import Path
import argparse

SCRIPT_NAME = Path(__file__).name


def block_to_chunk(x: int, z: int) -> tuple[int, int]:
    """Convert block coordinates to chunk coordinates (floor division)."""
    return x // 16, z // 16


def main():
    parser = argparse.ArgumentParser(
        usage=f"python {SCRIPT_NAME} -x [X coord] -y [Y coord] -z [Z coord]",
        description="Minecraft /forceload generator. Converts X, Y, and Z coordinates into chunk coordinates. Using /forceload on a chunk keeps it loaded for the entire server.",
    )

    parser.add_argument("-x", "--x", type=int, required=True, help="X coordinate")
    parser.add_argument("-y", "--y", type=int, required=True, help="Y coordinate")
    parser.add_argument("-z", "--z", type=int, required=True, help="Z coordinate")

    args = parser.parse_args()

    print(f"Converting input coordinates [{args.x}, {args.z}] to /forceload command\n")
    chunk_x, chunk_z = block_to_chunk(args.x, args.z)
    command = f"/forceload add {chunk_x} {chunk_z} {chunk_x} {chunk_z}"

    print(f"> Forceload command:")
    print(f"    {command}")

    print(f"\nIf you are in the Nether/End, use this instead:")
    print(f"  /execute in minecraft:overworld run {command}")


if __name__ == "__main__":
    main()

