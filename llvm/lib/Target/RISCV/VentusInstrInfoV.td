///
//===----------------------------------------------------------------------===//

include "VentusInstrFormatsV.td"

//===----------------------------------------------------------------------===//
// Operand and SDNode transformation definitions.
	@@ -44,23 +44,6 @@ class VTypeIOp<int VTypeINum> : Operand<XLenVT> {
def VTypeIOp10 : VTypeIOp<10>;
def VTypeIOp11 : VTypeIOp<11>;

def simm5 : Operand<XLenVT>, ImmLeaf<XLenVT, [{return isInt<5>(Imm);}]> {
  let ParserMatchClass = SImmAsmOperand<5>;
  let EncoderMethod = "getImmOpValue";
	@@ -104,27 +87,27 @@ def simm5_plus1_nonzero : ImmLeaf<XLenVT,
class VMVRSched<int n>: Sched <[!cast<SchedReadWrite>("WriteVMov" # n # "V"),
                                !cast<SchedReadWrite>("ReadVMov" # n # "V")]>;

class VLESched : Sched <[WriteVLDE, ReadVLDX]>;

class VSESched : Sched <[WriteVSTE, ReadVSTEV, ReadVSTX]>;

class VLSSched<int n> : Sched <[!cast<SchedReadWrite>("WriteVLDS" # n),
                                ReadVLDX, ReadVLDSX]>;

class VSSSched<int n> : Sched <[!cast<SchedReadWrite>("WriteVSTS" # n),
                                !cast<SchedReadWrite>("ReadVSTS" # n # "V"),
                                ReadVSTX, ReadVSTSX]>;

class VLXSched<int n, string o> :
  Sched <[!cast<SchedReadWrite>("WriteVLD" # o # "X" # n),
          ReadVLDX, !cast<SchedReadWrite>("ReadVLD" # o # "XV")]>;

class VSXSched<int n, string o> :
  Sched <[!cast<SchedReadWrite>("WriteVST" # o # "X" # n),
          !cast<SchedReadWrite>("ReadVST" # o # "X" # n),
          ReadVSTX, !cast<SchedReadWrite>("ReadVST" # o # "XV")]>;

class VLFSched : Sched <[ReadVLDX]>;

//===----------------------------------------------------------------------===//
// Instruction class templates
//===----------------------------------------------------------------------===//
let hasSideEffects = 0, mayLoad = 1, mayStore = 0 in {
// unit-stride load vd, (rs1), vm
class VUnitStrideLoad<RISCVWidth width, string opcodestr>
    : RVInstVLU<0b000, width.Value{3}, LUMOPUnitStride, width.Value{2-0},
                (outs VGPR_32:$vd),
                (ins GPRMem:$rs1), opcodestr, "$vd, (${rs1})">;

let RVVConstraint = NoConstraint in {
// unit-stride whole register load vl<nf>r.v vd, (rs1)
class VWholeLoad<bits<3> nf, RISCVWidth width, string opcodestr, RegisterClass VRC>
    : RVInstVLU<nf, width.Value{3}, LUMOPUnitStrideWholeReg,
                width.Value{2-0}, (outs VRC:$vd), (ins GPRMem:$rs1),
                opcodestr, "$vd, (${rs1})"> {
  let Uses = [];
}
} // RVVConstraint = NoConstraint
} // hasSideEffects = 0, mayLoad = 1, mayStore = 0

let hasSideEffects = 0, mayLoad = 0, mayStore = 1 in {
// unit-stride store vd, vs3, (rs1), vm
class VUnitStrideStore<RISCVWidth width, string opcodestr>
    : RVInstVSU<0b000, width.Value{3}, SUMOPUnitStride, width.Value{2-0},
                (outs), (ins VGPR_32:$vs3, GPRMem:$rs1), opcodestr,
                "$vs3, (${rs1})">;

// vs<nf>r.v vd, (rs1)
class VWholeStore<bits<3> nf, string opcodestr, RegisterClass VRC>
    : RVInstVSU<nf, 0, SUMOPUnitStrideWholeReg,
                0b000, (outs), (ins VRC:$vs3, GPRMem:$rs1),
                opcodestr, "$vs3, (${rs1})"> {
  let Uses = [];
}
} // hasSideEffects = 0, mayLoad = 0, mayStore = 1

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
// op vd, vs2, vs1
class VALUVV<bits<6> funct6, RISCVVFormat opv, string opcodestr>
    : RVInstVV<funct6, opv, (outs VGPR_32:$vd),
                (ins VGPR_32:$vs2, VGPR_32:$vs1),
                opcodestr, "$vd, $vs2, $vs1">;

// op vd, vs1, vs2 (reverse the order of vs1 and vs2)
class VALUrVV<bits<6> funct6, RISCVVFormat opv, string opcodestr>
    : RVInstVV<funct6, opv, (outs VGPR_32:$vd),
                (ins VGPR_32:$vs1, VGPR_32:$vs2),
                opcodestr, "$vd, $vs1, $vs2">;


// op vd, vs2, rs1
class VALUVX<bits<6> funct6, RISCVVFormat opv, string opcodestr>
    : RVInstVX<funct6, opv, (outs VGPR_32:$vd),
                (ins VGPR_32:$vs2, GPR:$rs1),
                opcodestr, "$vd, $vs2, $rs1">;

// op vd, rs1, vs2 (reverse the order of rs1 and vs2)
class VALUrVX<bits<6> funct6, RISCVVFormat opv, string opcodestr>
    : RVInstVX<funct6, opv, (outs VGPR_32:$vd),
                (ins GPR:$rs1, VGPR_32:$vs2),
                opcodestr, "$vd, $rs1, $vs2">;

// op vd, vs2, imm
class VALUVI<bits<6> funct6, string opcodestr, Operand optype = simm5>
    : RVInstIVI<funct6, (outs VGPR_32:$vd),
                (ins VGPR_32:$vs2, optype:$imm),
                opcodestr, "$vd, $vs2, $imm">;

// op vd, vs2, rs1 (Float)
class VALUVF<bits<6> funct6, RISCVVFormat opv, string opcodestr>
    : RVInstVX<funct6, opv, (outs VGPR_32:$vd),
                (ins VGPR_32:$vs2, FPR32:$rs1),
                opcodestr, "$vd, $vs2, $rs1">;

// op vd, rs1, vs2 (Float) (reverse the order of rs1 and vs2)
class VALUrVF<bits<6> funct6, RISCVVFormat opv, string opcodestr>
    : RVInstVX<funct6, opv, (outs VGPR_32:$vd),
                (ins FPR32:$rs1, VGPR_32:$vs2),
                opcodestr, "$vd, $rs1, $vs2">;

// op vd, vs2 (use vs1 as instruction encoding)
class VALUVs2<bits<6> funct6, bits<5> vs1, RISCVVFormat opv, string opcodestr>
    : RVInstV<funct6, vs1, opv, (outs VGPR_32:$vd),
               (ins VGPR_32:$vs2),
               opcodestr, "$vd, $vs2">;
} // hasSideEffects = 0, mayLoad = 0, mayStore = 0

//===----------------------------------------------------------------------===//
// Combination of instruction classes.
// Use these multiclasses to define instructions more easily.
//===----------------------------------------------------------------------===//

multiclass VALU_IV_V_X_I<string opcodestr, bits<6> funct6, Operand optype = simm5, string vw = "v"> {
  def V  : VALUVV<funct6, OPIVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVIALUV_UpperBound, ReadVIALUV_UpperBound,
                  ReadVIALUV_UpperBound]>;
  def X  : VALUVX<funct6, OPIVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVIALUX_UpperBound, ReadVIALUV_UpperBound,
                  ReadVIALUX_UpperBound]>;
  def I  : VALUVI<funct6, opcodestr # "." # vw # "i", optype>,
           Sched<[WriteVIALUI_UpperBound, ReadVIALUV_UpperBound]>;
}

multiclass VALU_IV_V_X<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V  : VALUVV<funct6, OPIVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVIALUV_UpperBound, ReadVIALUV_UpperBound,
                  ReadVIALUV_UpperBound]>;
  def X  : VALUVX<funct6, OPIVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVIALUX_UpperBound, ReadVIALUV_UpperBound,
                  ReadVIALUX_UpperBound]>;
}

multiclass VALU_IV_X_I<string opcodestr, bits<6> funct6, Operand optype = simm5, string vw = "v"> {
  def X  : VALUVX<funct6, OPIVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVIALUV_UpperBound, ReadVIALUV_UpperBound,
                  ReadVIALUX_UpperBound]>;
  def I  : VALUVI<funct6, opcodestr # "." # vw # "i", optype>,
           Sched<[WriteVIALUI_UpperBound, ReadVIALUV_UpperBound]>;
}

multiclass VALU_MV_V_X<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V  : VALUVV<funct6, OPMVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVIWALUV_UpperBound, ReadVIWALUV_UpperBound,
                  ReadVIWALUV_UpperBound]>;
  def X  : VALUVX<funct6, OPMVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVIWALUX_UpperBound, ReadVIWALUV_UpperBound,
                  ReadVIWALUX_UpperBound]>;
}

multiclass VMAC_MV_V_X<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V : VALUrVV<funct6, OPMVV, opcodestr # "." # vw # "v">,
          Sched<[WriteVIMulAddV_UpperBound, ReadVIMulAddV_UpperBound,
                 ReadVIMulAddV_UpperBound]>;
  def X : VALUrVX<funct6, OPMVX, opcodestr # "." # vw # "x">,
          Sched<[WriteVIMulAddX_UpperBound, ReadVIMulAddV_UpperBound,
                 ReadVIMulAddX_UpperBound]>;
}

multiclass VWMAC_MV_V_X<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V : VALUrVV<funct6, OPMVV, opcodestr # "." # vw # "v">,
          Sched<[WriteVIWMulAddV_UpperBound, ReadVIWMulAddV_UpperBound,
                 ReadVIWMulAddV_UpperBound]>;
  def X : VALUrVX<funct6, OPMVX, opcodestr # "." # vw # "x">,
          Sched<[WriteVIWMulAddX_UpperBound, ReadVIWMulAddV_UpperBound,
                 ReadVIWMulAddX_UpperBound]>;
}

multiclass VWMAC_MV_X<string opcodestr, bits<6> funct6, string vw = "v"> {
  def X : VALUrVX<funct6, OPMVX, opcodestr # "." # vw # "x">,
          Sched<[WriteVIWMulAddX_UpperBound, ReadVIWMulAddV_UpperBound,
                 ReadVIWMulAddX_UpperBound]>;
}

multiclass VALU_MV_VS2<string opcodestr, bits<6> funct6, bits<5> vs1> {
  def "" : VALUVs2<funct6, vs1, OPMVV, opcodestr>,
           Sched<[WriteVExtV_UpperBound, ReadVExtV_UpperBound]>;
}

multiclass VALU_FV_V_F<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V : VALUVV<funct6, OPFVV, opcodestr # "." # vw # "v">,
          Sched<[WriteVFALUV_UpperBound, ReadVFALUV_UpperBound,
                 ReadVFALUV_UpperBound]>;
  def F : VALUVF<funct6, OPFVF, opcodestr # "." # vw # "f">,
          Sched<[WriteVFALUF_UpperBound, ReadVFALUV_UpperBound,
                 ReadVFALUF_UpperBound]>;
}

multiclass VALU_FV_F<string opcodestr, bits<6> funct6, string vw = "v"> {
  def F : VALUVF<funct6, OPFVF, opcodestr # "." # vw # "f">,
          Sched<[WriteVFALUF_UpperBound, ReadVFALUV_UpperBound,
                 ReadVFALUF_UpperBound]>;
}

multiclass VWALU_FV_V_F<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V : VALUVV<funct6, OPFVV, opcodestr # "." # vw # "v">,
          Sched<[WriteVFWALUV_UpperBound, ReadVFWALUV_UpperBound,
                 ReadVFWALUV_UpperBound]>;
  def F : VALUVF<funct6, OPFVF, opcodestr # "." # vw # "f">,
          Sched<[WriteVFWALUF_UpperBound, ReadVFWALUV_UpperBound,
                 ReadVFWALUF_UpperBound]>;
}

multiclass VMUL_FV_V_F<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V : VALUVV<funct6, OPFVV, opcodestr # "." # vw # "v">,
          Sched<[WriteVFMulV_UpperBound, ReadVFMulV_UpperBound,
                 ReadVFMulV_UpperBound]>;
  def F : VALUVF<funct6, OPFVF, opcodestr # "." # vw # "f">,
          Sched<[WriteVFMulF_UpperBound, ReadVFMulV_UpperBound,
                 ReadVFMulF_UpperBound]>;
}

multiclass VDIV_FV_V_F<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V : VALUVV<funct6, OPFVV, opcodestr # "." # vw # "v">,
          Sched<[WriteVFDivV_UpperBound, ReadVFDivV_UpperBound,
                 ReadVFDivV_UpperBound]>;
  def F : VALUVF<funct6, OPFVF, opcodestr # "." # vw # "f">,
          Sched<[WriteVFDivF_UpperBound, ReadVFDivV_UpperBound,
                 ReadVFDivF_UpperBound]>;
}

multiclass VRDIV_FV_F<string opcodestr, bits<6> funct6, string vw = "v"> {
  def F : VALUVF<funct6, OPFVF, opcodestr # "." # vw # "f">,
          Sched<[WriteVFDivF_UpperBound, ReadVFDivV_UpperBound,
                 ReadVFDivF_UpperBound]>;
}

multiclass VWMUL_FV_V_F<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V : VALUVV<funct6, OPFVV, opcodestr # "." # vw # "v">,
          Sched<[WriteVFWMulV_UpperBound, ReadVFWMulV_UpperBound,
                 ReadVFWMulV_UpperBound]>;
  def F : VALUVF<funct6, OPFVF, opcodestr # "." # vw # "f">,
          Sched<[WriteVFWMulF_UpperBound, ReadVFWMulV_UpperBound,
                 ReadVFWMulF_UpperBound]>;
}

multiclass VMAC_FV_V_F<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V : VALUrVV<funct6, OPFVV, opcodestr # "." # vw # "v">,
          Sched<[WriteVFMulAddV_UpperBound, ReadVFMulAddV_UpperBound,
                 ReadVFMulAddV_UpperBound]>;
  def F : VALUrVF<funct6, OPFVF, opcodestr # "." # vw # "f">,
          Sched<[WriteVFMulAddF_UpperBound, ReadVFMulAddV_UpperBound,
                 ReadVFMulAddF_UpperBound]>;
}

multiclass VWMAC_FV_V_F<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V : VALUrVV<funct6, OPFVV, opcodestr # "." # vw # "v">,
          Sched<[WriteVFWMulAddV_UpperBound, ReadVFWMulAddV_UpperBound,
                 ReadVFWMulAddV_UpperBound]>;
  def F : VALUrVF<funct6, OPFVF, opcodestr # "." # vw # "f">,
          Sched<[WriteVFWMulAddF_UpperBound, ReadVFWMulAddV_UpperBound,
                 ReadVFWMulAddF_UpperBound]>;
}

multiclass VSQR_FV_VS2<string opcodestr, bits<6> funct6, bits<5> vs1> {
  def "" : VALUVs2<funct6, vs1, OPFVV, opcodestr>,
           Sched<[WriteVFSqrtV_UpperBound, ReadVFSqrtV_UpperBound]>;
}

multiclass VRCP_FV_VS2<string opcodestr, bits<6> funct6, bits<5> vs1> {
  def "" : VALUVs2<funct6, vs1, OPFVV, opcodestr>,
           Sched<[WriteVFRecpV_UpperBound, ReadVFRecpV_UpperBound]>;
}

multiclass VCMP_FV_V_F<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V : VALUVV<funct6, OPFVV, opcodestr # "." # vw # "v">,
          Sched<[WriteVFCmpV_UpperBound, ReadVFCmpV_UpperBound,
                 ReadVFCmpV_UpperBound]>;
  def F : VALUVF<funct6, OPFVF, opcodestr # "." # vw # "f">,
          Sched<[WriteVFCmpF_UpperBound, ReadVFCmpV_UpperBound,
                 ReadVFCmpF_UpperBound]>;
}

multiclass VCMP_FV_F<string opcodestr, bits<6> funct6, string vw = "v"> {
  def F : VALUVF<funct6, OPFVF, opcodestr # "." # vw # "f">,
          Sched<[WriteVFCmpF_UpperBound, ReadVFCmpV_UpperBound,
                 ReadVFCmpF_UpperBound]>;
}

multiclass VSGNJ_FV_V_F<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V : VALUVV<funct6, OPFVV, opcodestr # "." # vw # "v">,
          Sched<[WriteVFSgnjV_UpperBound, ReadVFSgnjV_UpperBound,
                 ReadVFSgnjV_UpperBound]>;
  def F : VALUVF<funct6, OPFVF, opcodestr # "." # vw # "f">,
          Sched<[WriteVFSgnjF_UpperBound, ReadVFSgnjV_UpperBound,
                 ReadVFSgnjF_UpperBound]>;
}

multiclass VCLS_FV_VS2<string opcodestr, bits<6> funct6, bits<5> vs1> {
  def "" : VALUVs2<funct6, vs1, OPFVV, opcodestr>,
           Sched<[WriteVFClassV_UpperBound, ReadVFClassV_UpperBound]>;
}

multiclass VCVTF_IV_VS2<string opcodestr, bits<6> funct6, bits<5> vs1> {
  def "" : VALUVs2<funct6, vs1, OPFVV, opcodestr>,
           Sched<[WriteVFCvtIToFV_UpperBound, ReadVFCvtIToFV_UpperBound]>;
}

multiclass VCVTI_FV_VS2<string opcodestr, bits<6> funct6, bits<5> vs1> {
  def "" : VALUVs2<funct6, vs1, OPFVV, opcodestr>,
           Sched<[WriteVFCvtFToIV_UpperBound, ReadVFCvtFToIV_UpperBound]>;
}

multiclass VWCVTF_IV_VS2<string opcodestr, bits<6> funct6, bits<5> vs1> {
  def "" : VALUVs2<funct6, vs1, OPFVV, opcodestr>,
           Sched<[WriteVFWCvtIToFV_UpperBound, ReadVFWCvtIToFV_UpperBound]>;
}

multiclass VWCVTI_FV_VS2<string opcodestr, bits<6> funct6, bits<5> vs1> {
  def "" : VALUVs2<funct6, vs1, OPFVV, opcodestr>,
           Sched<[WriteVFWCvtFToIV_UpperBound, ReadVFWCvtFToIV_UpperBound]>;
}

multiclass VWCVTF_FV_VS2<string opcodestr, bits<6> funct6, bits<5> vs1> {
  def "" : VALUVs2<funct6, vs1, OPFVV, opcodestr>,
           Sched<[WriteVFWCvtFToFV_UpperBound, ReadVFWCvtFToFV_UpperBound]>;
}

multiclass VNCVTF_IV_VS2<string opcodestr, bits<6> funct6, bits<5> vs1> {
  def "" : VALUVs2<funct6, vs1, OPFVV, opcodestr>,
           Sched<[WriteVFNCvtIToFV_UpperBound, ReadVFNCvtIToFV_UpperBound]>;
}

multiclass VNCVTI_FV_VS2<string opcodestr, bits<6> funct6, bits<5> vs1> {
  def "" : VALUVs2<funct6, vs1, OPFVV, opcodestr>,
           Sched<[WriteVFNCvtFToIV_UpperBound, ReadVFNCvtFToIV_UpperBound]>;
}

multiclass VNCVTF_FV_VS2<string opcodestr, bits<6> funct6, bits<5> vs1> {
  def "" : VALUVs2<funct6, vs1, OPFVV, opcodestr>,
           Sched<[WriteVFNCvtFToFV_UpperBound, ReadVFNCvtFToFV_UpperBound]>;
}

multiclass VRED_MV_V<string opcodestr, bits<6> funct6> {
  def _VS : VALUVV<funct6, OPMVV, opcodestr # ".vs">,
            Sched<[WriteVIRedV, ReadVIRedV, ReadVIRedV0]>;
}

multiclass VWRED_IV_V<string opcodestr, bits<6> funct6> {
  def _VS : VALUVV<funct6, OPIVV, opcodestr # ".vs">,
            Sched<[WriteVIWRedV, ReadVIWRedV, ReadVIWRedV0]>;
}

multiclass VRED_FV_V<string opcodestr, bits<6> funct6> {
  def _VS : VALUVV<funct6, OPFVV, opcodestr # ".vs">,
            Sched<[WriteVFRedV, ReadVFRedV, ReadVFRedV0]>;
}

multiclass VREDO_FV_V<string opcodestr, bits<6> funct6> {
  def _VS : VALUVV<funct6, OPFVV, opcodestr # ".vs">,
            Sched<[WriteVFRedOV, ReadVFRedOV, ReadVFRedOV0]>;
}

multiclass VWRED_FV_V<string opcodestr, bits<6> funct6> {
  def _VS : VALUVV<funct6, OPFVV, opcodestr # ".vs">,
            Sched<[WriteVFWRedV, ReadVFWRedV, ReadVFWRedV0]>;
}

multiclass VWREDO_FV_V<string opcodestr, bits<6> funct6> {
  def _VS : VALUVV<funct6, OPFVV, opcodestr # ".vs">,
            Sched<[WriteVFWRedOV, ReadVFWRedOV, ReadVFWRedOV0]>;
}

multiclass VMSFS_MV_V<string opcodestr, bits<6> funct6, bits<5> vs1> {
  def "" : VALUVs2<funct6, vs1, OPMVV, opcodestr>,
           Sched<[WriteVMSFSV, ReadVMSFSV]>;
}

multiclass VMIOT_MV_V<string opcodestr, bits<6> funct6, bits<5> vs1> {
  def "" : VALUVs2<funct6, vs1, OPMVV, opcodestr>,
           Sched<[WriteVMIotV, ReadVMIotV]>;
}

multiclass VSHT_IV_V_X_I<string opcodestr, bits<6> funct6, Operand optype = simm5, string vw = "v"> {
  def V  : VALUVV<funct6, OPIVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVShiftV_UpperBound, ReadVShiftV_UpperBound,
                  ReadVShiftV_UpperBound]>;
  def X  : VALUVX<funct6, OPIVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVShiftX_UpperBound, ReadVShiftV_UpperBound,
                  ReadVShiftX_UpperBound]>;
  def I  : VALUVI<funct6, opcodestr # "." # vw # "i", optype>,
           Sched<[WriteVShiftI_UpperBound, ReadVShiftV_UpperBound]>;
}

multiclass VNSHT_IV_V_X_I<string opcodestr, bits<6> funct6, Operand optype = simm5, string vw = "v"> {
  def V  : VALUVV<funct6, OPIVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVNShiftV_UpperBound, ReadVNShiftV_UpperBound,
                  ReadVNShiftV_UpperBound]>;
  def X  : VALUVX<funct6, OPIVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVNShiftX_UpperBound, ReadVNShiftV_UpperBound,
                  ReadVNShiftX_UpperBound]>;
  def I  : VALUVI<funct6, opcodestr # "." # vw # "i", optype>,
           Sched<[WriteVNShiftI_UpperBound, ReadVNShiftV_UpperBound]>;
}

multiclass VCMP_IV_V_X_I<string opcodestr, bits<6> funct6, Operand optype = simm5, string vw = "v"> {
  def V  : VALUVV<funct6, OPIVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVICmpV_UpperBound, ReadVICmpV_UpperBound,
                  ReadVICmpV_UpperBound]>;
  def X  : VALUVX<funct6, OPIVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVICmpX_UpperBound, ReadVICmpV_UpperBound,
                  ReadVICmpX_UpperBound]>;
  def I  : VALUVI<funct6, opcodestr # "." # vw # "i", optype>,
           Sched<[WriteVICmpI_UpperBound, ReadVICmpV_UpperBound]>;
}

multiclass VCMP_IV_X_I<string opcodestr, bits<6> funct6, Operand optype = simm5, string vw = "v"> {
  def X  : VALUVX<funct6, OPIVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVICmpV_UpperBound, ReadVICmpV_UpperBound,
                  ReadVICmpX_UpperBound]>;
  def I  : VALUVI<funct6, opcodestr # "." # vw # "i", optype>,
           Sched<[WriteVICmpI_UpperBound, ReadVICmpV_UpperBound]>;
}

multiclass VCMP_IV_V_X<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V  : VALUVV<funct6, OPIVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVICmpV_UpperBound, ReadVICmpV_UpperBound,
                  ReadVICmpV_UpperBound]>;
  def X  : VALUVX<funct6, OPIVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVICmpX_UpperBound, ReadVICmpV_UpperBound,
                  ReadVICmpX_UpperBound]>;
}

multiclass VMUL_MV_V_X<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V  : VALUVV<funct6, OPMVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVIMulV_UpperBound, ReadVIMulV_UpperBound,
                  ReadVIMulV_UpperBound]>;
  def X  : VALUVX<funct6, OPMVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVIMulX_UpperBound, ReadVIMulV_UpperBound,
                  ReadVIMulX_UpperBound]>;
}

multiclass VWMUL_MV_V_X<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V  : VALUVV<funct6, OPMVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVIWMulV_UpperBound, ReadVIWMulV_UpperBound,
                  ReadVIWMulV_UpperBound]>;
  def X  : VALUVX<funct6, OPMVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVIWMulX_UpperBound, ReadVIWMulV_UpperBound,
                  ReadVIWMulX_UpperBound]>;
}

multiclass VDIV_MV_V_X<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V  : VALUVV<funct6, OPMVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVIDivV_UpperBound, ReadVIDivV_UpperBound,
                  ReadVIDivV_UpperBound]>;
  def X  : VALUVX<funct6, OPMVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVIDivX_UpperBound, ReadVIDivV_UpperBound,
                  ReadVIDivX_UpperBound]>;
}

multiclass VSALU_IV_V_X_I<string opcodestr, bits<6> funct6, Operand optype = simm5, string vw = "v"> {
  def V  : VALUVV<funct6, OPIVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVSALUV_UpperBound, ReadVSALUV_UpperBound,
                  ReadVSALUV_UpperBound]>;
  def X  : VALUVX<funct6, OPIVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVSALUX_UpperBound, ReadVSALUV_UpperBound,
                  ReadVSALUX_UpperBound]>;
  def I  : VALUVI<funct6, opcodestr # "." # vw # "i", optype>,
           Sched<[WriteVSALUI_UpperBound, ReadVSALUV_UpperBound]>;
}

multiclass VSALU_IV_V_X<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V  : VALUVV<funct6, OPIVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVSALUV_UpperBound, ReadVSALUV_UpperBound,
                  ReadVSALUV_UpperBound]>;
  def X  : VALUVX<funct6, OPIVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVSALUX_UpperBound, ReadVSALUV_UpperBound,
                  ReadVSALUX_UpperBound]>;
}

multiclass VAALU_MV_V_X<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V  : VALUVV<funct6, OPMVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVAALUV_UpperBound, ReadVAALUV_UpperBound,
                  ReadVAALUV_UpperBound]>;
  def X  : VALUVX<funct6, OPMVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVAALUX_UpperBound, ReadVAALUV_UpperBound,
                  ReadVAALUX_UpperBound]>;
}

multiclass VSMUL_IV_V_X<string opcodestr, bits<6> funct6, string vw = "v"> {
  def V  : VALUVV<funct6, OPIVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVSMulV_UpperBound, ReadVSMulV_UpperBound,
                  ReadVSMulV_UpperBound]>;
  def X  : VALUVX<funct6, OPIVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVSMulX_UpperBound, ReadVSMulV_UpperBound,
                  ReadVSMulX_UpperBound]>;
}

multiclass VSSHF_IV_V_X_I<string opcodestr, bits<6> funct6, Operand optype = simm5, string vw = "v"> {
  def V  : VALUVV<funct6, OPIVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVSShiftV_UpperBound, ReadVSShiftV_UpperBound,
                  ReadVSShiftV_UpperBound]>;
  def X  : VALUVX<funct6, OPIVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVSShiftX_UpperBound, ReadVSShiftV_UpperBound,
                  ReadVSShiftX_UpperBound]>;
  def I  : VALUVI<funct6, opcodestr # "." # vw # "i", optype>,
           Sched<[WriteVSShiftI_UpperBound, ReadVSShiftV_UpperBound]>;
}

multiclass VNCLP_IV_V_X_I<string opcodestr, bits<6> funct6, Operand optype = simm5, string vw = "v"> {
  def V  : VALUVV<funct6, OPIVV, opcodestr # "." # vw # "v">,
           Sched<[WriteVNClipV_UpperBound, ReadVNClipV_UpperBound,
                  ReadVNClipV_UpperBound]>;
  def X  : VALUVX<funct6, OPIVX, opcodestr # "." # vw # "x">,
           Sched<[WriteVNClipX_UpperBound, ReadVNClipV_UpperBound,
                  ReadVNClipX_UpperBound]>;
  def I  : VALUVI<funct6, opcodestr # "." # vw # "i", optype>,
           Sched<[WriteVNClipI_UpperBound, ReadVNClipV_UpperBound]>;
}

multiclass VWholeLoadN<bits<3> nf, string opcodestr, RegisterClass VRC> {
	@@ -902,101 +618,57 @@ multiclass VWholeLoadEEW64<bits<3> nf, string opcodestr, RegisterClass VRC, Sche
// Instructions
//===----------------------------------------------------------------------===//

foreach eew = [8, 16, 32] in {
  defvar w = !cast<RISCVWidth>("LSWidth" # eew);

  // Ventus use Vector Unit-Stride Instructions as basic load/store like sALU's
  // lb/lh/lw.
  // TODO: We may add load multiple byte/short/word version of it.
  def VLE#eew#_V : VUnitStrideLoad<w, "vle"#eew#".v">, VLESched;
  def VSE#eew#_V  : VUnitStrideStore<w,  "vse"#eew#".v">, VSESched;
}

let Predicates = [HasVInstructions] in {
defm VL1R : VWholeLoadN<0, "vl1r", VGPR_32>;

def VS1R_V : VWholeStore<0, "vs1r.v", VGPR_32>,
             Sched<[WriteVST1R, ReadVST1R, ReadVSTX]>;

def : InstAlias<"vl1r.v $vd, (${rs1})", (VL1RE8_V VGPR_32:$vd, GPR:$rs1)>;
} // Predicates = [HasVInstructions]

let Predicates = [HasVInstructionsI64] in {
// Vector Unit-Stride Instructions
def VLE64_V : VUnitStrideLoad<LSWidth64, "vle64.v">,
              VLESched;

def VSE64_V : VUnitStrideStore<LSWidth64, "vse64.v">,
              VSESched;

defm VL1R: VWholeLoadEEW64<0, "vl1r", VGPR_32, WriteVLD1R>;
} // Predicates = [HasVInstructionsI64]

let Predicates = [HasVInstructions] in {
// Vector Single-Width Integer Add and Subtract
defm VADD_V : VALU_IV_V_X_I<"vadd", 0b000000>;
defm VSUB_V : VALU_IV_V_X<"vsub", 0b000010>;
defm VRSUB_V : VALU_IV_X_I<"vrsub", 0b000011>;

def : InstAlias<"vneg.v $vd, $vs", (VRSUB_VX VGPR_32:$vd, VGPR_32:$vs, X0, zero_reg)>;

// Vector Widening Integer Add/Subtract
// Refer to 11.2 Widening Vector Arithmetic Instructions
// The destination vector register group cannot overlap a source vector
// register group of a different element width, otherwise an illegal
// instruction exception is raised.
let Constraints = "@earlyclobber $vd" in {
let RVVConstraint = WidenV in {
defm VWADDU_V : VALU_MV_V_X<"vwaddu", 0b110000>;
defm VWSUBU_V : VALU_MV_V_X<"vwsubu", 0b110010>;
defm VWADD_V : VALU_MV_V_X<"vwadd", 0b110001>;
defm VWSUB_V : VALU_MV_V_X<"vwsub", 0b110011>;
} // RVVConstraint = WidenV
// Set earlyclobber for following instructions for second operands.
// This has the downside that the earlyclobber constraint is too coarse and
// will impose unnecessary restrictions by not allowing the destination to
// overlap with the first (wide) operand.
	@@ -1008,14 +680,14 @@ defm VWSUB_W : VALU_MV_V_X<"vwsub", 0b110111, "w">;
} // RVVConstraint = WidenW
} // Constraints = "@earlyclobber $vd"

def : InstAlias<"vwcvt.x.x.v $vd, $vs",
                (VWADD_VX VGPR_32:$vd, VGPR_32:$vs, X0)>;
def : InstAlias<"vwcvt.x.x.v $vd, $vs",
                (VWADD_VX VGPR_32:$vd, VGPR_32:$vs, X0, zero_reg)>;
def : InstAlias<"vwcvtu.x.x.v $vd, $vs",
                (VWADDU_VX VGPR_32:$vd, VGPR_32:$vs, X0)>;
def : InstAlias<"vwcvtu.x.x.v $vd, $vs",
                (VWADDU_VX VGPR_32:$vd, VGPR_32:$vs, X0, zero_reg)>;

// Vector Integer Extension
defm VZEXT_VF8 : VALU_MV_VS2<"vzext.vf8", 0b010010, 0b00010>;
	@@ -1025,27 +697,15 @@ defm VSEXT_VF4 : VALU_MV_VS2<"vsext.vf4", 0b010010, 0b00101>;
defm VZEXT_VF2 : VALU_MV_VS2<"vzext.vf2", 0b010010, 0b00110>;
defm VSEXT_VF2 : VALU_MV_VS2<"vsext.vf2", 0b010010, 0b00111>;

// Vector Bitwise Logical Instructions
defm VAND_V : VALU_IV_V_X_I<"vand", 0b001001>;
defm VOR_V : VALU_IV_V_X_I<"vor", 0b001010>;
defm VXOR_V : VALU_IV_V_X_I<"vxor", 0b001011>;

def : InstAlias<"vnot.v $vd, $vs",
                (VXOR_VI VGPR_32:$vd, VGPR_32:$vs, -1)>;
def : InstAlias<"vnot.v $vd, $vs",
                (VXOR_VI VGPR_32:$vd, VGPR_32:$vs, -1, zero_reg)>;

// Vector Single-Width Bit Shift Instructions
defm VSLL_V : VSHT_IV_V_X_I<"vsll", 0b100101, uimm5>;
	@@ -1055,17 +715,16 @@ defm VSRA_V : VSHT_IV_V_X_I<"vsra", 0b101001, uimm5>;
// Vector Narrowing Integer Right Shift Instructions
// Refer to 11.3. Narrowing Vector Arithmetic Instructions
// The destination vector register group cannot overlap the first source
// vector register group (specified by vs2).
let Constraints = "@earlyclobber $vd" in {
defm VNSRL_W : VNSHT_IV_V_X_I<"vnsrl", 0b101100, uimm5, "w">;
defm VNSRA_W : VNSHT_IV_V_X_I<"vnsra", 0b101101, uimm5, "w">;
} // Constraints = "@earlyclobber $vd"

def : InstAlias<"vncvt.x.x.w $vd, $vs",
                (VNSRL_WX VGPR_32:$vd, VGPR_32:$vs, X0)>;
def : InstAlias<"vncvt.x.x.w $vd, $vs",
                (VNSRL_WX VGPR_32:$vd, VGPR_32:$vs, X0, zero_reg)>;

// Vector Integer Comparison Instructions
let RVVConstraint = NoConstraint in {
	@@ -1079,14 +738,14 @@ defm VMSGTU_V : VCMP_IV_X_I<"vmsgtu", 0b011110>;
defm VMSGT_V : VCMP_IV_X_I<"vmsgt", 0b011111>;
} // RVVConstraint = NoConstraint

def : InstAlias<"vmsgtu.vv $vd, $va, $vb",
                (VMSLTU_VV VGPR_32:$vd, VGPR_32:$vb, VGPR_32:$va), 0>;
def : InstAlias<"vmsgt.vv $vd, $va, $vb",
                (VMSLT_VV VGPR_32:$vd, VGPR_32:$vb, VGPR_32:$va), 0>;
def : InstAlias<"vmsgeu.vv $vd, $va, $vb",
                (VMSLEU_VV VGPR_32:$vd, VGPR_32:$vb, VGPR_32:$va), 0>;
def : InstAlias<"vmsge.vv $vd, $va, $vb",
                (VMSLE_VV VGPR_32:$vd, VGPR_32:$vb, VGPR_32:$va), 0>;

let isCodeGenOnly = 0, isAsmParserOnly = 1, hasSideEffects = 0, mayLoad = 0,
    mayStore = 0 in {
	@@ -1095,42 +754,30 @@ let isCodeGenOnly = 0, isAsmParserOnly = 1, hasSideEffects = 0, mayLoad = 0,
// immediate like we do for signed. To match the GNU assembler we will use
// vmseq/vmsne.vv with the same register for both operands which we can't do
// from an InstAlias.
def PseudoVMSGEU_VI : Pseudo<(outs VGPR_32:$vd),
                             (ins VGPR_32:$vs2, simm5_plus1:$imm),
                             [], "vmsgeu.vi", "$vd, $vs2, $imm">;
def PseudoVMSLTU_VI : Pseudo<(outs VGPR_32:$vd),
                             (ins VGPR_32:$vs2, simm5_plus1:$imm),
                             [], "vmsltu.vi", "$vd, $vs2, $imm">;
// Handle signed with pseudos as well for more consistency in the
// implementation.
def PseudoVMSGE_VI : Pseudo<(outs VGPR_32:$vd),
                            (ins VGPR_32:$vs2, simm5_plus1:$imm),
                            [], "vmsge.vi", "$vd, $vs2, $imm">;
def PseudoVMSLT_VI : Pseudo<(outs VGPR_32:$vd),
                            (ins VGPR_32:$vs2, simm5_plus1:$imm),
                            [], "vmslt.vi", "$vd, $vs2, $imm">;
}

let isCodeGenOnly = 0, isAsmParserOnly = 1, hasSideEffects = 0, mayLoad = 0,
    mayStore = 0 in {
def PseudoVMSGEU_VX : Pseudo<(outs VGPR_32:$vd),
                             (ins VGPR_32:$vs2, GPR:$rs1),
                             [], "vmsgeu.vx", "$vd, $vs2, $rs1">;
def PseudoVMSGE_VX : Pseudo<(outs VGPR_32:$vd),
                            (ins VGPR_32:$vs2, GPR:$rs1),
                            [], "vmsge.vx", "$vd, $vs2, $rs1">;
}

// Vector Integer Min/Max Instructions
	@@ -1172,22 +819,19 @@ defm VWMACCSU_V : VWMAC_MV_V_X<"vwmaccsu", 0b111111>;
defm VWMACCUS_V : VWMAC_MV_X<"vwmaccus", 0b111110>;
} // Constraints = "@earlyclobber $vd", RVVConstraint = WidenV

// Vector Integer Move Instructions
let hasSideEffects = 0, mayLoad = 0, mayStore = 0, vs2 = 0,
    RVVConstraint = NoConstraint  in {
// op vd, vs1
def VMV_V_V : RVInstVV<0b010111, OPIVV, (outs VGPR_32:$vd),
                       (ins VGPR_32:$vs1), "vmv.v.v", "$vd, $vs1">,
              Sched<[WriteVIMovV_UpperBound, ReadVIMovV_UpperBound]>;
// op vd, rs1
def VMV_V_X : RVInstVX<0b010111, OPIVX, (outs VGPR_32:$vd),
                       (ins GPR:$rs1), "vmv.v.x", "$vd, $rs1">,
              Sched<[WriteVIMovX_UpperBound, ReadVIMovX_UpperBound]>;
// op vd, imm
def VMV_V_I : RVInstIVI<0b010111, (outs VGPR_32:$vd),
                       (ins simm5:$imm), "vmv.v.i", "$vd, $imm">,
              Sched<[WriteVIMovI_UpperBound]>;
} // hasSideEffects = 0, mayLoad = 0, mayStore = 0
	@@ -1234,7 +878,7 @@ let RVVConstraint = WidenV in {
defm VFWADD_V : VWALU_FV_V_F<"vfwadd", 0b110000>;
defm VFWSUB_V : VWALU_FV_V_F<"vfwsub", 0b110010>;
} // RVVConstraint = WidenV
// Set earlyclobber for following instructions for second operands.
// This has the downside that the earlyclobber constraint is too coarse and
// will impose unnecessary restrictions by not allowing the destination to
// overlap with the first (wide) operand.
	@@ -1298,14 +942,14 @@ defm VFSGNJ_V : VSGNJ_FV_V_F<"vfsgnj", 0b001000>;
defm VFSGNJN_V : VSGNJ_FV_V_F<"vfsgnjn", 0b001001>;
defm VFSGNJX_V : VSGNJ_FV_V_F<"vfsgnjx", 0b001010>;

def : InstAlias<"vfneg.v $vd, $vs",
                (VFSGNJN_VV VGPR_32:$vd, VGPR_32:$vs, VGPR_32:$vs)>;
def : InstAlias<"vfneg.v $vd, $vs",
                (VFSGNJN_VV VGPR_32:$vd, VGPR_32:$vs, VGPR_32:$vs, zero_reg)>;
def : InstAlias<"vfabs.v $vd, $vs",
                (VFSGNJX_VV VGPR_32:$vd, VGPR_32:$vs, VGPR_32:$vs)>;
def : InstAlias<"vfabs.v $vd, $vs",
                (VFSGNJX_VV VGPR_32:$vd, VGPR_32:$vs, VGPR_32:$vs, zero_reg)>;

// Vector Floating-Point Compare Instructions
let RVVConstraint = NoConstraint, mayRaiseFPException = true in {
	@@ -1317,28 +961,19 @@ defm VMFGT_V : VCMP_FV_F<"vmfgt", 0b011101>;
defm VMFGE_V : VCMP_FV_F<"vmfge", 0b011111>;
} // RVVConstraint = NoConstraint, mayRaiseFPException = true

def : InstAlias<"vmfgt.vv $vd, $va, $vb",
                (VMFLT_VV VGPR_32:$vd, VGPR_32:$vb, VGPR_32:$va), 0>;
def : InstAlias<"vmfge.vv $vd, $va, $vb$vm",
                (VMFLE_VV VGPR_32:$vd, VGPR_32:$vb, VGPR_32:$va), 0>;

// Vector Floating-Point Classify Instruction
defm VFCLASS_V : VCLS_FV_VS2<"vfclass.v", 0b010011, 0b10000>;

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
// Vector Floating-Point Move Instruction
let RVVConstraint = NoConstraint in
let vs2 = 0 in
def VFMV_V_F : RVInstVX<0b010111, OPFVF, (outs VGPR_32:$vd),
                       (ins FPR32:$rs1), "vfmv.v.f", "$vd, $rs1">,
               Sched<[WriteVFMovV_UpperBound, ReadVFMovF_UpperBound]>;

	@@ -1405,7 +1040,7 @@ defm VREDXOR : VRED_MV_V<"vredxor", 0b000011>;

// Vector Widening Integer Reduction Instructions
let Constraints = "@earlyclobber $vd", RVVConstraint = NoConstraint in {
// Set earlyclobber for following instructions for second operands.
// This has the downside that the earlyclobber constraint is too coarse and
// will impose unnecessary restrictions by not allowing the destination to
// overlap with the first (wide) operand.
	@@ -1428,12 +1063,12 @@ defm VFREDMIN : VRED_FV_V<"vfredmin", 0b000101>;
}
} // RVVConstraint = NoConstraint

def : InstAlias<"vfredsum.vs $vd, $vs2, $vs1",
                (VFREDUSUM_VS VGPR_32:$vd, VGPR_32:$vs2, VGPR_32:$vs1), 0>;

// Vector Widening Floating-Point Reduction Instructions
let Constraints = "@earlyclobber $vd", RVVConstraint = NoConstraint in {
// Set earlyclobber for following instructions for second operands.
// This has the downside that the earlyclobber constraint is too coarse and
// will impose unnecessary restrictions by not allowing the destination to
// overlap with the first (wide) operand.
	@@ -1443,124 +1078,61 @@ defm VFWREDUSUM : VWRED_FV_V<"vfwredusum", 0b110001>;
}
} // Constraints = "@earlyclobber $vd", RVVConstraint = NoConstraint

def : InstAlias<"vfwredsum.vs $vd, $vs2, $vs1",
                (VFWREDUSUM_VS VGPR_32:$vd, VGPR_32:$vs2, VGPR_32:$vs1), 0>;
} // Predicates = [HasVInstructionsAnyF]

let Predicates = [HasVInstructions] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0 in {
// Integer Scalar Move Instructions
let RVVConstraint = NoConstraint in {
def VMV_X_S : RVInstV<0b010000, 0b00000, OPMVV, (outs GPR:$vd),
                      (ins VGPR_32:$vs2), "vmv.x.s", "$vd, $vs2">,
              Sched<[WriteVIMovVX, ReadVIMovVX]>;
let Constraints = "$vd = $vd_wb" in
def VMV_S_X : RVInstV2<0b010000, 0b00000, OPMVX, (outs VGPR_32:$vd_wb),
                      (ins VGPR_32:$vd, GPR:$rs1), "vmv.s.x", "$vd, $rs1">,
              Sched<[WriteVIMovXV, ReadVIMovXV, ReadVIMovXX]>;
} // RVVConstraint = NoConstraint

} // hasSideEffects = 0, mayLoad = 0, mayStore = 0

} // Predicates = [HasVInstructions]


let Predicates = [HasVInstructionsAnyF] in {

let hasSideEffects = 0, mayLoad = 0, mayStore = 0,
    RVVConstraint = NoConstraint  in {
// Floating-Point Scalar Move Instructions
def VFMV_F_S : RVInstV<0b010000, 0b00000, OPFVV, (outs FPR32:$vd),
                      (ins VGPR_32:$vs2), "vfmv.f.s", "$vd, $vs2">,
               Sched<[WriteVFMovVF, ReadVFMovVF]>;
let Constraints = "$vd = $vd_wb" in
def VFMV_S_F : RVInstV2<0b010000, 0b00000, OPFVF, (outs VGPR_32:$vd_wb),
                       (ins VGPR_32:$vd, FPR32:$rs1), "vfmv.s.f", "$vd, $rs1">,
               Sched<[WriteVFMovFV, ReadVFMovFV, ReadVFMovFX]>;

} // hasSideEffects = 0, mayLoad = 0, mayStore = 0

} // Predicates = [HasVInstructionsAnyF]

// TODO: Fix it!
/*
let hasSideEffects = 0, mayLoad = 0, mayStore = 0,
    RVVConstraint = NoConstraint in {
// A future extension may relax the vector register alignment restrictions.
foreach n = [1] in {
  defvar vrc = !cast<RegisterClass>(!if(!eq(n, 1), "VR", "VRM"#n));
  def VMV#n#R_V  : RVInstV<0b100111, !add(n, -1), OPIVI, (outs vrc:$vd),
                           (ins vrc:$vs2), "vmv" # n # "r.v", "$vd, $vs2">,
                   VMVRSched<n> {
    let Uses = [];
  }
}
} // hasSideEffects = 0, mayLoad = 0, mayStore = 0
} // Predicates = [HasVInstructions]
*/

include "VentusInstrInfoVPseudos.td"