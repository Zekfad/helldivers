#include <type/magic.pat>


namespace hash {
    enum hash_name : u64 {};
    enum file_type : u64 {
        ah_bin = 0x2A0A70ACFE476E1D,
        animation = 0x931E336D7646CC26, // Animation
        bik = 0xAA5965F03029FA18, // Bink Video
        bones = 0x18DEAD01056B72E9, // Had clear text that looked like a skeleton bone tree
        camera_shake = 0xFCAAF813B4D3CC1E,
        cloth = 0xD7014A50477953E0, // Cloth
        config = 0x82645835E6B73232,
        entity = 0x9831CA893B0D087D, // Entity
        font = 0x9EFE0A916AAE7880, // Font
        geleta = 0xB8FD4D2CEDE20ED7,
        geometry_group = 0xC4F0F4BE7FB0C8D6,
        hash_lookup = 0xE3F2851035957AF5,
        havok_ai_properties = 0x6592B918E67F082C,
        havok_physics_properties = 0xF7A09F8BB35A1D49,
        ik_skeleton = 0x57A13425279979D7, // References Havok content
        level = 0x2A690FD348FE9AC5, // Level
        lua = 0xA14E8DFA2CD117E2, // Lua (LuaJIT bytecode mostly)
        material = 0xEAC0B497876ADEDF, // Material
        mouse_cursor = 0xB277B11FE4A61D37,
        network_config = 0x3B1FA9E8F6BAC374,
        package = 0xAD9C6D9ED1E5E77A,
        particles = 0xA8193123526FAD64, // Particles
        physics = 0x5F7203C8F280DAB8, // References Havok content
        prefab = 0xAB2F78E885F513C6, // Prefab
        ragdoll_profile = 0x1D59BD6687DB6B33, // References Havok content.
        render_config = 0x27862FE24795319C, // Render Config
        renderable = 0x7910103158FC1DE9,
        runtime_font = 0x05106B81DCD58A13, // TrueType Font (.ttf) // 0x80 or 0x24 "Header" Siz
        shader_library = 0xE5EE32A477239A93,
        shader_library_group = 0x9E5C3CC74575AEB5,
        shading_environment = 0xFE73C7DCFF8A7CA5, // Shading Environement
        shading_environment_mapping = 0x250E0A11AC8E26F8, // Shading Environment Mapping
        speedtree = 0xE985C5F61C169997, // SpeedTree
        state_machine = 0xA486D4045106165C, // State Machine
        strings = 0x0D972BAB10B40FD3,
        texture = 0xCD4238C6A0C69E32, // Texture (.texture), (DDS = 0xC0 "Header" Size)
        texture_atlas = 0x9199BB50B6896F02,
        unit = 0xE0A48D0BE9A7453F, // Unit, MeshInfo+Mesh
        vector_field = 0xF7505933166D6755, // Vector Field
        wwise_bank = 0x535A7BD3E650D799, // Wwise Sound Bank, 0x16 "Header" Size
        wwise_dep = 0xAF32095C82F2B070, // Wwise Dependencies (.wwise_dep), Contains text referencing audio
        wwise_metadata = 0xD50A8B7E1C82B110,
        wwise_properties = 0x5FDD5FE391076F9F,
        wwise_stream = 0x504B55235D21440E, // Wwise Encoded Media
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
        le u64 __unk02; // looked like a hash, but seems 
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
