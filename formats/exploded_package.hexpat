#include <type/magic.pat>
#pragma pattern_limit 100000000
#pragma array_limit 100000000

// Exploded database

// Such packages contains resources (textures, models, scripts, etc.)

// Filenames (paths) and extensions are hashed with murmur64

// For scripts Helldivers is using LuaJIT 2.0.3

// Looks like entries can contain variants, or some small textures are packed
// into single entry, this still needs investigation 

// Lua script
namespace lua_resource {
    // Data format
    enum format_t : u32 {
        // Probably used only in engine debug
        source_format          = 0x0,
        // Compiled Lua bytecode
        genric_bytecode_format = 0x1,
        // LuaJIT bytecode
        luajit2_format         = 0x2,
        bad_format             = 0x3,
    };

    // Header
    struct header_t {
        le u32 size;
        le format_t format;
    };

    // Resource
    struct resource {
        header_t header;
        char data[header.size];
    };
}

// Lookup table for some known types
enum file_type_t : u64 {
    timpani_master       = 0x00a3e6c59a2b9c6c,
    strings              = 0x0d972bab10b40fd3,
    bones                = 0x18dead01056b72e9,
    render_config        = 0x27862fe24795319c,
    level                = 0x2a690fd348fe9ac5,
    input                = 0x2bbcabe5074ade9e,
    network_config       = 0x3b1fa9e8f6bac374,
    ugg                  = 0x712d6e3dd1024c9c,
    xml                  = 0x76015845a6003765,
    wav                  = 0x786f65c00a816b19,
    baked_lighting       = 0x7ffdb779b04e4ed1,
    config               = 0x82645835e6b73232,
    data                 = 0x8fd0d44d20650b68,
    flow                 = 0x92d3ee038eeb610d,
    animation            = 0x931e336d7646cc26,
    timpani_bank         = 0x99736be1fff739a4,
    shader_library_group = 0x9e5c3cc74575aeb5,
    font                 = 0x9efe0a916aae7880,
    lua                  = 0xa14e8dfa2cd117e2,
    state_machine        = 0xa486d4045106165c,
    particles            = 0xa8193123526fad64,
    upb                  = 0xa99510c6e86dd3c2,
    package              = 0xad9c6d9ed1e5e77a,
    surface_properties   = 0xad2d3fa30d9ab394,
    mouse_cursor         = 0xb277b11fe4a61d37,
    physics_properties   = 0xbf21403a3ab0bbb1,
    shader               = 0xcce8d5b5f5ae333f,
    texture              = 0xcd4238c6a0c69e32,
    sound_environment    = 0xd8b27864a97ffdd7,
    animation_curves     = 0xdcfb9e18fff13984,
    unit                 = 0xe0a48d0be9a7453f,
    static_pvs           = 0xe3f0baa17d620321,
    shader_library       = 0xe5ee32a477239a93,
    material             = 0xeac0b497876adedf,
    vector_field         = 0xf7505933166d6755,
    spu_job              = 0xf97af9983c05b950,
    ivf                  = 0xfa4a8e091a91201e,
    shading_environment  = 0xfe73c7dcff8a7ca5,
    wwise_stream         = 0x504b55235d21440e,
    wwise_bank           = 0x535a7bd3e650d799,
    wwise_metadata       = 0xd50a8b7e1c82b110,
    wwise_dep            = 0xaf32095c82f2b070,
};

// Full filename (path)
struct filename_t {
    // Resouce type or extension
    le file_type_t type_hash;
    // Resource path without extension
    le u64 path_hash;
};

// Variant header
struct variant_header_t {
    le u32 unknown;
    le u32 inline_size;
    le u32 stream_size;
};

// Variant contents
struct variant_data_t<auto type, auto size> {
    if (type == file_type_t::lua)
        lua_resource::resource script;
    else if (type == file_type_t::texture)
        char dds_data[size];
    else
        char data[size];
};

// This variable is used to reference size of variant
u32 variant_idx = 0;

// Resource variant
struct variant_t {
    // references inline_size from variant header
    variant_data_t<parent.filename.type_hash, parent.variants_headers[variant_idx].inline_size> data;
    variant_idx += 1;
};

// Entry
struct entry_t {
    filename_t filename;
    le u32 variants_count;
    le u32 stream_offset;

    variant_header_t variants_headers[variants_count];

    variant_idx = 0;
    variant_t variants[variants_count];
};

// Package
struct package_t {
    le u32 entries_count;
    // Seems like it's the same for every package in the game
    char magic[256];
    filename_t files[entries_count];
    entry_t entries[entries_count];
};

package_t package @ 0x00;
