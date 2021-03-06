/-
Copyright (c) 2017 Johannes Hölzl. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Johannes Hölzl, Mario Carneiro

Finite sets.
-/
import data.set.lattice data.nat.basic logic.function
       data.fintype

open set lattice function

universes u v w
variables {α : Type u} {β : Type v} {ι : Sort w}

namespace set

/-- A set is finite if the subtype is a fintype, i.e. there is a
  list that enumerates its members. -/
def finite (s : set α) : Prop := nonempty (fintype s)

/-- A set is infinite if it is not finite. -/
def infinite (s : set α) : Prop := ¬ finite s

/-- Construct a fintype from a finset with the same elements. -/
def fintype_of_finset {p : set α} (s : finset α) (H : ∀ x, x ∈ s ↔ x ∈ p) : fintype p :=
fintype.subtype s H

@[simp] theorem card_fintype_of_finset {p : set α} (s : finset α) (H : ∀ x, x ∈ s ↔ x ∈ p) :
  @fintype.card p (fintype_of_finset s H) = s.card :=
fintype.subtype_card s H

theorem card_fintype_of_finset' {p : set α} (s : finset α)
  (H : ∀ x, x ∈ s ↔ x ∈ p) [fintype p] : fintype.card p = s.card :=
by rw ← card_fintype_of_finset s H; congr

/-- Construct a finset enumerating a set `s`, given a `fintype` instance.  -/
def to_finset (s : set α) [fintype s] : finset α :=
⟨(@finset.univ s _).1.map subtype.val,
 multiset.nodup_map (λ a b, subtype.eq) finset.univ.2⟩

@[simp] theorem mem_to_finset {s : set α} [fintype s] {a : α} : a ∈ s.to_finset ↔ a ∈ s :=
by simp [to_finset]

@[simp] theorem mem_to_finset_val {s : set α} [fintype s] {a : α} : a ∈ s.to_finset.1 ↔ a ∈ s :=
mem_to_finset

noncomputable instance finite.fintype {s : set α} (h : finite s) : fintype s :=
classical.choice h

/-- Get a finset from a finite set -/
noncomputable def finite.to_finset {s : set α} (h : finite s) : finset α :=
@set.to_finset _ _ (finite.fintype h)

@[simp] theorem finite.mem_to_finset {s : set α} {h : finite s} {a : α} : a ∈ h.to_finset ↔ a ∈ s :=
@mem_to_finset _ _ (finite.fintype h) _

theorem finite_mem_finset (s : finset α) : finite {a | a ∈ s} :=
⟨fintype_of_finset s (λ _, iff.rfl)⟩

instance decidable_mem_of_fintype [decidable_eq α] (s : set α) [fintype s] (a) : decidable (a ∈ s) :=
decidable_of_iff _ mem_to_finset

instance fintype_empty : fintype (∅ : set α) :=
fintype_of_finset ∅ $ by simp

@[simp] theorem empty_card : fintype.card (∅ : set α) = 0 := rfl

@[simp] theorem finite_empty : @finite α ∅ := ⟨set.fintype_empty⟩

def fintype_insert' {a : α} (s : set α) [fintype s] (h : a ∉ s) : fintype (insert a s : set α) :=
fintype_of_finset ⟨a :: s.to_finset.1,
  multiset.nodup_cons_of_nodup (by simp [h]) s.to_finset.2⟩ $ by simp

theorem card_fintype_insert' {a : α} (s : set α) [fintype s] (h : a ∉ s) :
  @fintype.card _ (fintype_insert' s h) = fintype.card s + 1 :=
by rw [fintype_insert', card_fintype_of_finset];
   simp [finset.card, to_finset]; refl

instance fintype_insert [decidable_eq α] (a : α) (s : set α) [fintype s] : fintype (insert a s : set α) :=
if h : a ∈ s then by rwa [insert_eq, union_eq_self_of_subset_left (singleton_subset_iff.2 h)]
else fintype_insert' _ h

@[simp] theorem card_insert [decidable_eq α] {a : α} (s : set α) [fintype s] (h : a ∉ s) :
  fintype.card (insert a s : set α) = fintype.card s + 1 :=
by rw ← card_fintype_insert' s h; congr

@[simp] theorem finite_insert (a : α) {s : set α} : finite s → finite (insert a s)
| ⟨h⟩ := ⟨@set.fintype_insert _ (classical.dec_eq α) _ _ h⟩

lemma to_finset_insert [decidable_eq α] {a : α} {s : set α} (hs : finite s) :
  (finite_insert a hs).to_finset = insert a hs.to_finset :=
finset.ext.mpr $ by simp

@[elab_as_eliminator]
theorem finite.induction_on {C : set α → Prop} {s : set α} (h : finite s)
  (H0 : C ∅) (H1 : ∀ {a s}, a ∉ s → finite s → C s → C (insert a s)) : C s :=
let ⟨t⟩ := h in by exactI
match s.to_finset, @mem_to_finset _ s _ with
| ⟨l, nd⟩, al := begin
    change ∀ a, a ∈ l ↔ a ∈ s at al,
    clear _let_match _match t h, revert s nd al,
    refine multiset.induction_on l _ (λ a l IH, _); intros s nd al,
    { rw show s = ∅, from eq_empty_iff_forall_not_mem.2 (by simpa using al),
      exact H0 },
    { rw ← show insert a {x | x ∈ l} = s, from set.ext (by simpa using al),
      cases multiset.nodup_cons.1 nd with m nd',
      refine H1 _ ⟨finset.subtype.fintype ⟨l, nd'⟩⟩ (IH nd' (λ _, iff.rfl)),
      exact m }
  end
end

@[elab_as_eliminator]
theorem finite.dinduction_on {C : ∀s:set α, finite s → Prop} {s : set α} (h : finite s)
  (H0 : C ∅ finite_empty)
  (H1 : ∀ {a s}, a ∉ s → ∀h:finite s, C s h → C (insert a s) (finite_insert a h)) :
  C s h :=
have ∀h:finite s, C s h,
  from finite.induction_on h (assume h, H0) (assume a s has hs ih h, H1 has hs (ih _)),
this h

instance fintype_singleton (a : α) : fintype ({a} : set α) :=
fintype_insert' _ (not_mem_empty _)

@[simp] theorem card_singleton (a : α) :
  fintype.card ({a} : set α) = 1 :=
by rw [show fintype.card ({a} : set α) = _, from
    card_fintype_insert' ∅ (not_mem_empty a)]; refl

@[simp] theorem finite_singleton (a : α) : finite ({a} : set α) :=
⟨set.fintype_singleton _⟩

instance fintype_union [decidable_eq α] (s t : set α) [fintype s] [fintype t] : fintype (s ∪ t : set α) :=
fintype_of_finset (s.to_finset ∪ t.to_finset) $ by simp

theorem finite_union {s t : set α} : finite s → finite t → finite (s ∪ t)
| ⟨hs⟩ ⟨ht⟩ := ⟨@set.fintype_union _ (classical.dec_eq α) _ _ hs ht⟩

instance fintype_sep (s : set α) (p : α → Prop) [fintype s] [decidable_pred p] : fintype ({a ∈ s | p a} : set α) :=
fintype_of_finset (s.to_finset.filter p) $ by simp

instance fintype_inter (s t : set α) [fintype s] [decidable_pred t] : fintype (s ∩ t : set α) :=
set.fintype_sep s t

def fintype_subset (s : set α) {t : set α} [fintype s] [decidable_pred t] (h : t ⊆ s) : fintype t :=
by rw ← inter_eq_self_of_subset_right h; apply_instance

theorem finite_subset {s : set α} : finite s → ∀ {t : set α}, t ⊆ s → finite t
| ⟨hs⟩ t h := ⟨@set.fintype_subset _ _ _ hs (classical.dec_pred t) h⟩

instance fintype_image [decidable_eq β] (s : set α) (f : α → β) [fintype s] : fintype (f '' s) :=
fintype_of_finset (s.to_finset.image f) $ by simp

instance fintype_range [decidable_eq β] (f : α → β) [fintype α] : fintype (range f) :=
fintype_of_finset (finset.univ.image f) $ by simp [range]

theorem finite_image {s : set α} (f : α → β) : finite s → finite (f '' s)
| ⟨h⟩ := ⟨@set.fintype_image _ _ (classical.dec_eq β) _ _ h⟩

def fintype_of_fintype_image [decidable_eq β] (s : set α)
  {f : α → β} {g} (I : is_partial_inv f g) [fintype (f '' s)] : fintype s :=
fintype_of_finset ⟨_, @multiset.nodup_filter_map β α g _
  (@injective_of_partial_inv_right _ _ f g I) (f '' s).to_finset.2⟩ $ λ a,
begin
  suffices : (∃ b x, f x = b ∧ g b = some a ∧ x ∈ s) ↔ a ∈ s,
  by simpa [exists_and_distrib_left.symm, and.comm, and.left_comm, and.assoc],
  rw exists_swap,
  suffices : (∃ x, x ∈ s ∧ g (f x) = some a) ↔ a ∈ s, {simpa [and.comm, and.left_comm, and.assoc]},
  simp [I _, (injective_of_partial_inv I).eq_iff]
end

theorem finite_of_finite_image {s : set α} {f : α → β}
  (I : injective f) : finite (f '' s) → finite s | ⟨hs⟩ :=
by haveI := classical.dec_eq β; exact
⟨fintype_of_fintype_image _ (partial_inv_of_injective I)⟩

theorem finite_preimage {s : set β} {f : α → β}
  (I : injective f) (h : finite s) : finite (f ⁻¹' s) :=
finite_of_finite_image I (finite_subset h (image_preimage_subset f s))

instance fintype_Union [decidable_eq α] {ι : Type*} [fintype ι]
  (f : ι → set α) [∀ i, fintype (f i)] : fintype (⋃ i, f i) :=
fintype_of_finset (finset.univ.bind (λ i, (f i).to_finset)) $ by simp

theorem finite_Union {ι : Type*} [fintype ι] {f : ι → set α} (H : ∀i, finite (f i)) : finite (⋃ i, f i) :=
⟨@set.fintype_Union _ (classical.dec_eq α) _ _ _ (λ i, finite.fintype (H i))⟩

theorem finite_sUnion {s : set (set α)} (h : finite s) (H : ∀t∈s, finite t) : finite (⋃₀ s) :=
by rw sUnion_eq_Union'; haveI := finite.fintype h;
   apply finite_Union; simpa using H

instance fintype_lt_nat (n : ℕ) : fintype {i | i < n} :=
fintype_of_finset (finset.range n) $ by simp

instance fintype_le_nat (n : ℕ) : fintype {i | i ≤ n} :=
by simpa [nat.lt_succ_iff] using set.fintype_lt_nat (n+1)

lemma finite_le_nat (n : ℕ) : finite {i | i ≤ n} := ⟨set.fintype_le_nat _⟩

instance fintype_prod (s : set α) (t : set β) [fintype s] [fintype t] : fintype (set.prod s t) :=
fintype_of_finset (s.to_finset.product t.to_finset) $ by simp

lemma finite_prod {s : set α} {t : set β} : finite s → finite t → finite (set.prod s t)
| ⟨hs⟩ ⟨ht⟩ := by exactI ⟨set.fintype_prod s t⟩

end set

namespace finset
variables [decidable_eq α] [decidable_eq β]
variables {s t u : finset α} {f : α → β} {a : α}

/-- Convert a finset to a set in the natural way. -/
def to_set (s : finset α) : set α := {x | x ∈ s}

instance : has_lift (finset α) (set α) := ⟨to_set⟩

@[simp] lemma mem_coe : a ∈ (↑s : set α) = (a ∈ s) :=
rfl

lemma finite_to_set (s : finset α) : set.finite (↑s : set α) :=
set.finite_mem_finset s

@[simp] lemma coe_eq_coe : ((↑s : set α) = ↑t) ↔ s = t :=
by simp [finset.ext, set.set_eq_def]

@[simp] lemma coe_subseteq_coe : ((↑s : set α) ⊆ ↑t) ↔ s ⊆ t :=
by simp [finset.subset_iff, set.subset_def]

@[simp] lemma coe_empty : ↑(∅ : finset α) = (∅ : set α) :=
by simp [set.set_eq_def]

@[simp] lemma coe_insert : ↑(insert a s) = (insert a ↑s : set α) :=
by simp [set.set_eq_def]

@[simp] lemma coe_erase : ↑(erase s a) = (↑s \ {a} : set α) :=
by simp [set.set_eq_def, and_comm]

@[simp] lemma coe_sdiff : ↑(s \ t) = (↑s \ ↑t : set α) :=
by simp [set.set_eq_def]

@[simp] lemma coe_singleton : ↑({a} : finset α) = ({a} : set α) :=
by simp [set.set_eq_def]

@[simp] lemma coe_union : ↑(s ∪ t) = (↑s ∪ ↑t : set α) :=
by simp [set.set_eq_def]

@[simp] lemma coe_inter : ↑(s ∩ t) = (↑s ∩ ↑t : set α) :=
by simp [set.set_eq_def]

@[simp] lemma coe_image {f : α → β} : ↑(s.image f) = f '' ↑s :=
by simp [set.set_eq_def]

@[simp] lemma coe_bind {f : α → finset β} : ↑(s.bind f) = (⋃x ∈ (↑s : set α), ↑(f x) : set β) :=
by simp [set.set_eq_def]

@[simp] lemma coe_filter {p : α → Prop} [decidable_pred p] :
  ↑(s.filter p) = ({x ∈ ↑s | p x} : set α) :=
by simp [set.set_eq_def]

@[simp] lemma coe_to_finset {s : set α} {hs : set.finite s} : ↑(hs.to_finset) = s :=
by simp [set.set_eq_def]

end finset

namespace set

lemma infinite_univ_nat : infinite (univ : set ℕ) :=
assume (h : finite (univ : set ℕ)),
let ⟨n, hn⟩ := finset.exists_nat_subset_range h.to_finset in
have n ∈ finset.range n, from finset.subset_iff.mpr hn $ by simp,
by simp * at *

lemma not_injective_nat_fintype [fintype α] [decidable_eq α] {f : ℕ → α} : ¬ injective f :=
assume (h : injective f),
have finite (f '' univ),
  from finite_subset (finset.finite_to_set $ fintype.elems α) (assume a h, fintype.complete a),
have finite (univ : set ℕ), from finite_of_finite_image h this,
infinite_univ_nat this

lemma not_injective_int_fintype [fintype α] [decidable_eq α] {f : ℤ → α} : ¬ injective f :=
assume hf,
have injective (f ∘ (coe : ℕ → ℤ)), from injective_comp hf $ assume i j, int.of_nat_inj,
not_injective_nat_fintype this

end set
