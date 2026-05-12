# Dokumentacja Algorytmu Wyznaczania Ekstremów Wielomianu w Arytmetyce Stałoprzecinkowej

## 1. Wstęp
Algorytm służy do wyznaczania wartości minimalnej oraz maksymalnej wielomianu na zadanym przedziale $[a, b]$. Implementacja została zoptymalizowana pod kątem systemów wbudowanych i układów FPGA poprzez zastosowanie arytmetyki stałoprzecinkowej, co eliminuje potrzebę wykorzystania jednostki zmiennoprzecinkowej (FPU).

## 2. Reprezentacja danych (Fixed-Point Arithmetic)
W programie zastosowano format stałoprzecinkowy z parametrem $Q=16$ (format Q16.16).

*   **Skalowanie:** Wartości typu `float` są konwertowane na `int` poprzez pomnożenie przez współczynnik $2^{16}$ (przesunięcie bitowe w lewo o 16).
*   **Korekcja mnożenia:** Wynik mnożenia dwóch liczb w formacie Q16 musi zostać przesunięty o 16 bitów w prawo (`>> Q`), aby zachować poprawną pozycję kropki dziesiętnej i uniknąć przepełnienia formatu przy kolejnych operacjach.

## 3. Metoda obliczeniowa: Schemat Hornera
Do wyznaczania wartości wielomianu w konkretnym punkcie wykorzystano **Schemat Hornera**. Metoda ta minimalizuje liczbę operacji mnożenia, co bezpośrednio przekłada się na mniejsze zużycie zasobów logicznych w sprzęcie.

Wielomian obliczany jest iteracyjnie wg wzoru:
$$val = (\dots((a_n \cdot x + a_{n-1}) \cdot x + a_{n-2}) \dots ) + a_0$$

W każdej iteracji mnożenia (instrukcja `(val * current_x) >> Q`) następuje normalizacja wyniku do formatu stałoprzecinkowego.

## 4. Przebieg algorytmu
Proces wyszukiwania ekstremów odbywa się w następujących krokach:

1.  **Dyskretyzacja przedziału:** Przedział $[start, end]$ dzielony jest na $N$ równych kroków o długości `step_size`.
2.  **Inicjalizacja:** Obliczana jest wartość funkcji dla punktu początkowego, która staje się punktem odniesienia dla `min` i `max`.
3.  **Przeszukiwanie liniowe (Brute-force):**
    *   Algorytm iteruje przez wszystkie punkty $x_i$ od $1$ do $num\_steps$.
    *   Dla każdego punktu obliczana jest wartość $P(x_i)$.
    *   Następuje porównanie z zapamiętanym minimum i maksimum:
        ```python
        if current_val < min_val: update_min()
        if current_val > max_val: update_max()

4. **Konwersja zwrotna:** Po zakończeniu pętli, wyniki są dzielone przez $SCALE$, aby przywrócić je do formatu zmiennoprzecinkowego czytelnego dla użytkownika.

## 5. Charakterystyka techniczna

*   **Złożoność obliczeniowa:** $O(N \cdot M)$, gdzie $N$ to liczba kroków, a $M$ to stopień wielomianu.

*   **Precyzja:** Wynikowa dokładność zależy od gęstości próbkowania (liczby kroków) oraz rozdzielczości formatu $Q$.

*   **Zastosowanie:** Algorytm idealnie nadaje się do implementacji w językach HDL (Verilog/VHDL) oraz na mikrokontrolerach bez wsparcia dla liczb zmiennoprzecinkowych.
