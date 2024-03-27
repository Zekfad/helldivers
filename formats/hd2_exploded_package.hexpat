#include <type/magic.pat>


namespace hash {
    enum hash_name : u64 {};
    enum file_type : u64 {
        TRUETYPE_FONT               = 0x05106B81DCD58A13, // TrueType Font (.ttf) // 0x80 or 0x24 "Header" Size
        BONES                       = 0x18DEAD01056B72E9, // Had clear text that looked like a skeleton bone tree
        _HAVOK_1D59BD6687DB6B33     = 0x1D59BD6687DB6B33, // References Havok content.
        SHADING_ENVIRONMENT_MAPPING = 0x250E0A11AC8E26F8, // Shading Environment Mapping (.shading_environment_mapping)
        RENDER_CONFIG               = 0x27862FE24795319C, // Render Config (.render_config)
        LEVEL                       = 0x2A690FD348FE9AC5, // Level (.level)
        WWISE_STREAM                = 0x504B55235D21440E, // Wwise Encoded Media (.wwise_stream)
        WWISE_BANK                  = 0x535A7BD3E650D799, // Wwise Sound Bank (.wwise_bank), 0x16 "Header" Size
        HAVOK_57A13425279979D7      = 0x57A13425279979D7, // References Havok content.
        HAVOK_5F7203C8F280DAB8      = 0x5F7203C8F280DAB8, // References Havok content.
        _9199BB50B6896F02           = 0x9199BB50B6896F02, //
        ENTITY                      = 0x9831CA893B0D087D, // Entity (.entity)
        ANIMATION                   = 0x931E336D7646CC26, // Animation (.animation)
        FONT                        = 0x9EFE0A916AAE7880, // Font (.font)
        LUA                         = 0xA14E8DFA2CD117E2, // Lua (.lua), References Wwise Sound Banks
        STATE_MACHINE               = 0xA486D4045106165C, // State Machine (.state_machine)
        PARTICLES                   = 0xA8193123526FAD64, // Particles (.particles)
        BINK_VIDEO                  = 0xAA5965F03029FA18, // Bink Video (.bik)
        PREFAB                      = 0xAB2F78E885F513C6, // .prefab
        WWISDE_DEPENDENCIES         = 0xAF32095C82F2B070, // Wwise Dependencies (.wwise_dep), Contains text referencing audio
        _C4F0F4BE7FB0C8D6           = 0xC4F0F4BE7FB0C8D6, //
        TEXTURE                     = 0xCD4238C6A0C69E32, // Texture (.texture), (DDS = 0xC0 "Header" Size)
        CLOTH                       = 0xD7014A50477953E0, // Cloth (.cloth)
        UNIT                        = 0xE0A48D0BE9A7453F, // Unit (.unit), MeshInfo+Mesh
        SPEEDTREE                   = 0xE985C5F61C169997, // SpeedTree (.speedtree)
        MATERIAL                    = 0xEAC0B497876ADEDF, // Material (.material)
        VECTOR_FIELD                = 0xF7505933166D6755, // Vector Field (.vector_field)
        SHADING_ENVIRONMENT         = 0xFE73C7DCFF8A7CA5, // Shading Environement (.shading_environment)
    };
}

namespace archive {
    // Reversed (little endian)
    enum archive_version : u32 {
        hd1 = 0xf0000004,
        hd2 = 0xf0000011,
    };

    struct archive_header_t {
        le archive_version version;
        le u32 types_count;
        le u32 files_count;
        
        le u32 __unk00;
        le u32 __checksum; // crc32 of what?
        le u32 __unk01;
        le hash::hash_name hash;
        le u64 buffer_size;
        le u64 gpu_buffer_size;
        
        le u32 __unk02;
        le u32 __unk03;
        le u32 __unk04;
        le u32 __unk05;
        le u32 __unk06;
        le u32 __unk07;
    };

    struct type_t {
        le u32 __unk00;
        le u32 __unk01;
        le hash::file_type type;
        le u32 count;
        le u32 __unk02;
        le u32 alignment;
        le u32 gpu_alignment;
    };

    struct file_t<auto Size> {
        char test[Size];
    };

    struct file_header_t {
        le hash::hash_name name;
        le hash::file_type type;
        
        // aligned to alignment
        le u64 offset;
        // unaligned raw aux buffer
        le u64 stream_offset;
        // aligned to gpu_alignment
        le u64 gpu_offset;
        
        // aligned to 0x200
        // seems to be an offset of read buffer that have size of 0x200 per element
        le u64 buffer_offset;
        // aligned to 0x600
        // seems to be an offset of read buffer that have size of 0x600 per element
        le u64 gpu_buffer_offset;
        
        le u32 size;
        le u32 stream_size;
        le u32 gpu_stream_size;
        
        le u32 alignment;
        le u32 gpu_alignment;
        le u32 index;
        
        file_t<size> inline_file @ offset;
    };

    struct archive_t {
        archive_header_t header;
        type_t types[header.types_count];
        file_header_t files[header.files_count];
    };
}

archive::archive_t archive @ 0x0;
