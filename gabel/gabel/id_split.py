# SPDX-License-Identifier: CC0-1.0

def id_parent(i_id:str)->str:
    if "/" in i_id:
        return i_id.rpartition("/")[0]
    else:
        return None

def id_base(i_id:str)->str:
    if "/" in i_id:
        return i_id.rpartition("/")[2]
    else:
        return i_id
